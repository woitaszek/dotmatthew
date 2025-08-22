#!/bin/bash

# Azure CLI Status Display Script
#
# Print the current Azure login context with colorful icons and formatting.
#
# Usage: ./azi.sh or source this script to use the aza() function

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;37m'
readonly DARK_GRAY='\033[1;30m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Icon definitions (using Unicode characters)
readonly ICON_USER="👤"
readonly ICON_TENANT="🏢"
readonly ICON_SUBSCRIPTION="💳"
readonly ICON_ID="🔑"
readonly ICON_COUNT="📊"
readonly ICON_CHECK="✅"
readonly ICON_ERROR="❌"
readonly ICON_WARNING="⚠️"
readonly ICON_AZURE="☁️"

# Function to check token validity and expiration
check_token_status() {
    local -n status_ref=$1
    local -n expires_ref=$2
    local -n needs_refresh_ref=$3

    status_ref="Unknown"
    expires_ref=""
    needs_refresh_ref=false

    # Get token information from az account get-access-token
    local token_info
    if token_info=$(az account get-access-token --query "{expiresOn: expiresOn}" --output json 2>/dev/null); then
        expires_ref=$(echo "$token_info" | jq -r '.expiresOn // "Unknown"' 2>/dev/null)

        if [[ "$expires_ref" != "Unknown" && "$expires_ref" != "null" ]]; then
            # Convert expiration time to epoch seconds
            local expires_epoch
            if expires_epoch=$(date -d "$expires_ref" +%s 2>/dev/null); then
                local current_epoch
                current_epoch=$(date +%s)
                local time_remaining=$((expires_epoch - current_epoch))

                if [[ $time_remaining -gt 3600 ]]; then
                    # More than 1 hour remaining
                    status_ref="${GREEN}Valid${NC}"
                elif [[ $time_remaining -gt 300 ]]; then
                    # Between 5 minutes and 1 hour remaining
                    status_ref="${YELLOW}Expires Soon${NC}"
                elif [[ $time_remaining -gt 0 ]]; then
                    # Less than 5 minutes remaining
                    status_ref="${YELLOW}Expires Very Soon${NC}"
                    needs_refresh_ref=true
                else
                    # Token has expired
                    status_ref="${RED}Expired${NC}"
                    needs_refresh_ref=true
                fi
            else
                status_ref="${YELLOW}Parse Error${NC}"
            fi
        else
            status_ref="${YELLOW}Unknown Expiry${NC}"
        fi
    else
        status_ref="${RED}Token Check Failed${NC}"
        needs_refresh_ref=true
    fi
}

# Function to display Azure information
azi() {
    local mode="verbose"  # Default to verbose mode

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--short)
                mode="short"
                shift
                ;;
            -v|--verbose)
                mode="verbose"
                shift
                ;;
            -h|--help)
                echo "Usage: azi [OPTIONS]"
                echo "Display Azure CLI status information"
                echo ""
                echo "Options:"
                echo "  -s, --short     Display information in compact one-line format"
                echo "  -v, --verbose   Display information in multi-line format (default)"
                echo "  -h, --help      Show this help message"
                return 0
                ;;
            *)
                echo -e "${ICON_ERROR} ${RED}Unknown option: $1${NC}"
                echo "Use --help for usage information"
                return 1
                ;;
        esac
    done

    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        echo -e "${ICON_ERROR} ${RED}Azure CLI is not installed or not in PATH${NC}"
        return 1
    fi

    # Check that jq is installed
    if ! command -v jq &> /dev/null; then
        echo -e "${ICON_ERROR} ${RED}jq is not installed or not in PATH${NC}"
        return 1
    fi

    # Check if user is logged in
    if ! az account show &> /dev/null; then
        echo -e "${ICON_WARNING} ${YELLOW}Not logged into Azure. Run 'az login' to authenticate.${NC}"
        return 1
    fi

    # Get account information
    local account_info
    if ! account_info=$(az account show --output json); then
        echo -e "${ICON_ERROR} ${RED}Failed to retrieve Azure account information${NC}"
        return 1
    fi

    # Parse JSON data
    local user_name tenant_id subscription_name subscription_id
    user_name=$(echo "$account_info" | jq -r '.user.name // "Unknown"' 2>/dev/null)
    tenant_id=$(echo "$account_info" | jq -r '.tenantId // "Unknown"' 2>/dev/null)
    subscription_name=$(echo "$account_info" | jq -r '.name // "Unknown"' 2>/dev/null)
    subscription_id=$(echo "$account_info" | jq -r '.id // "Unknown"' 2>/dev/null)

    # Get userPrincipalName from Graph API
    local user_principal_name
    if ! user_principal_name=$(az ad signed-in-user show --query "userPrincipalName" -o tsv 2>/dev/null); then
        user_principal_name="Unknown"
    fi

    # Call the Graph API to get the tenant default domain name
    local tenant_data
    if ! tenant_data=$(az rest --method get --url "https://graph.microsoft.com/v1.0/tenantRelationships/microsoft.graph.findTenantInformationByTenantId(tenantId='$tenant_id')"); then
        tenant_data="Unknown"
    fi
    local tenant_name
    tenant_name=$(echo "$tenant_data" | jq -r '.defaultDomainName // "Unknown"' 2>/dev/null)

    # Get available subscription count for additional context
    local sub_count
    sub_count=$(az account list --query "length(@)" --output tsv 2>/dev/null || echo "?")

    # Check token expiration and validity
    local token_status token_expires needs_refresh
    check_token_status token_status token_expires needs_refresh

    # Display the information based on the selected mode
    if [[ "$mode" == "short" ]]; then
        # Short mode: existing one-line output
        echo -n -e "${ICON_AZURE} ${BOLD}${BLUE} Azure:${NC} "
        echo -n -e "${ICON_USER} ${GREEN}${user_name}${NC} ${DARK_GRAY}(${user_principal_name})${NC} ${GRAY}|${NC} "
        echo -n -e "${ICON_TENANT} ${PURPLE}${tenant_name}${NC} ${GRAY}|${NC} "
        echo -n -e "${ICON_SUBSCRIPTION} ${CYAN}${subscription_name}${NC} "
        echo -n -e "${DARK_GRAY}${subscription_id}${NC} "
        echo -n -e "${GRAY}(${sub_count} total)${NC} "
        echo -n -e "${GRAY}| Token:${NC} ${token_status}"
        if [[ -n "$token_expires" && "$token_expires" != "Unknown" ]]; then
            echo -e " ${DARK_GRAY}(expires: $(date -d "$token_expires" "+%H:%M" 2>/dev/null || echo "$token_expires"))${NC}"
        else
            echo ""
        fi
    else
        # Verbose mode: multi-line output with white labels
        echo -e "${ICON_AZURE} ${BLUE} Azure Status${NC}"
        echo -e "${ICON_USER} ${WHITE}User:${NC}               ${GREEN}${user_name}${NC}"
        echo -e "${ICON_USER} ${WHITE}User Principal:${NC}     ${DARK_GRAY}${user_principal_name}${NC}"
        echo -e "${ICON_TENANT} ${WHITE}Tenant:${NC}             ${PURPLE}${tenant_name}${NC}"
        echo -e "${ICON_SUBSCRIPTION} ${WHITE}Subscription Name:${NC}  ${CYAN}${subscription_name}${NC}"
        echo -e "${ICON_ID} ${WHITE}Subscription ID:${NC}    ${DARK_GRAY}${subscription_id}${NC}"
        echo -e "${ICON_COUNT} ${WHITE}Total Subs:${NC}         ${GRAY}${sub_count}${NC}"
        echo -n -e "${ICON_CHECK} ${WHITE}Token Status:${NC}       ${token_status}"
        if [[ -n "$token_expires" && "$token_expires" != "Unknown" ]]; then
            echo -e " ${DARK_GRAY}(expires: $(date -d "$token_expires" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "$token_expires"))${NC}"
        else
            echo ""
        fi

        # Show refresh warning if needed
        if [[ "$needs_refresh" == true ]]; then
            echo -e "${ICON_WARNING} ${YELLOW}Consider running 'az login' to refresh your authentication${NC}"
        fi
    fi
}

# If script is run directly (not sourced), execute the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    azi "$@"
fi