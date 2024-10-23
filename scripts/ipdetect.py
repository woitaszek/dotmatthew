#!/usr/bin/env python3

"""
ipdetect.py - Use multiple services to detect public IP addresses

This script uses multiple services to detect the public IP address of the
machine it is running on. This is useful when operating behind an
enterprise-grade NAT or firewall that may use multiple public IP addresses.
"""

import requests
import time
import sys

def get_public_ips():
    """
    Return a set of public IP addresses detected for this machine.
    """

    repeat = 3
    services = [
        'https://ifconfig.me/ip',
        'https://api.ipify.org',
        'https://icanhazip.com',
        'https://checkip.amazonaws.com',
        'https://ipinfo.io/ip',
        'https://wtfismyip.com/text',
        'https://ifconfig.co/ip',
    ]

    public_ips = set()

    for i in range(repeat):
        for service in services:

            try:
                print(f"\033[90mTrying {service}...\033[0m ", file=sys.stderr, end="")
                response = requests.get(service, timeout=2)

                if response.status_code == 200:
                    result = response.text.strip()
                    if result in public_ips:
                        print(f"{result} \033[94m\u2713\033[0m", file=sys.stderr) # Blue checkmark
                    else:
                        print(f"{result} \033[92m\u2713\033[0m ", file=sys.stderr) # Green checkmark
                    public_ips.add(result)

            except requests.RequestException:
                print(f"\033[91m\u2717\033[0m", file=sys.stderr) # Red X

            except Exception as e:
                print(f"\033[91m\u2717\033[0m {e}", file=sys.stderr) # Red X

        time.sleep(0.1)

    return public_ips


if __name__ == '__main__':
    public_ips = get_public_ips()
    public_ips = list(public_ips)
    public_ips.sort()
    print(",".join(public_ips))
