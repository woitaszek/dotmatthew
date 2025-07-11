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
readonly ICON_CHECK="✅"
readonly ICON_ERROR="❌"
readonly ICON_WARNING="⚠️"
readonly ICON_AZURE="☁️"

# Function to display Azure information
azi() {
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

    # Display the colorful status line components
    echo -n -e "${ICON_AZURE} ${BOLD}${BLUE} Azure:${NC} "
    echo -n -e "${ICON_USER} ${GREEN}${user_name}${NC} ${GRAY}|${NC} "
    echo -n -e "${ICON_TENANT} ${PURPLE}${tenant_name}${NC} ${GRAY}|${NC} "
    echo -n -e "${ICON_SUBSCRIPTION} ${CYAN}${subscription_name}${NC} "
    echo -n -e "${DARK_GRAY}${subscription_id}${NC} "
    echo -e "${GRAY}(${sub_count} total)${NC}"
}

# If script is run directly (not sourced), execute the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    azi
fi