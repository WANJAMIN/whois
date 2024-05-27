#!/bin/bash

display_logo() {
    local logo="\

 ▄▄▄▄▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄▄▄▄▄       ▄▄▄▄▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄▄▄▄▄
▐░░░░░░░░░░░▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▐░░░░░░░░░░░▐░░░░░░░░░░░▌
 ▀▀▀▀█░█▀▀▀▀▐░█▀▀▀▀▀▀▀█░▌     ▐░█▀▀▀▀▀▀▀█░▌▀▀▀▀█░█▀▀▀▀▐░█▀▀▀▀▀▀▀█░▌
     ▐░▌    ▐░▌       ▐░▌     ▐░▌       ▐░▌    ▐░▌    ▐░▌       ▐░▌
     ▐░▌    ▐░█▄▄▄▄▄▄▄█░▌     ▐░█▄▄▄▄▄▄▄█░▌    ▐░▌    ▐░▌       ▐░▌
     ▐░▌    ▐░░░░░░░░░░░▌     ▐░░░░░░░░░░░▌    ▐░▌    ▐░▌       ▐░▌
     ▐░▌    ▐░█▀▀▀▀▀▀▀▀▀      ▐░█▀▀▀▀█░█▀▀     ▐░▌    ▐░▌       ▐░▌
     ▐░▌    ▐░▌               ▐░▌     ▐░▌      ▐░▌    ▐░▌       ▐░▌
 ▄▄▄▄█░█▄▄▄▄▐░▌               ▐░▌      ▐░▌ ▄▄▄▄█░█▄▄▄▄▐░█▄▄▄▄▄▄▄█░▌
▐░░░░░░░░░░░▐░▌               ▐░▌       ▐░▐░░░░░░░░░░░▐░░░░░░░░░░░▌
 ▀▀▀▀▀▀▀▀▀▀▀ ▀                 ▀         ▀ ▀▀▀▀▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀▀▀▀


                                    version:- 1.0

                           https://github.com/XRIO0
NOTE:- READ THE README.txt FOR OPTION AND USE
"

    local delay=0.0001
    for (( i=0; i<${#logo}; i++ )); do
        echo -n "${logo:$i:1}"
        sleep "$delay"
    done
    echo
}

display_logo

show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  --help                Show this help message"
    echo "  --change-hostname     Change the hostname (requires new hostname as argument)"
    echo "  --change-mac          Change the MAC address (requires interface name as argument)"
    echo "  --dns-leak-test       Perform an extended DNS leak test"
    echo
    echo "Example:"
    echo "  $0 --change-hostname new-hostname"
    echo "  $0 --change-mac eth0"
    echo "  $0 --dns-leak-test"
}

get_public_ip() {
    wget -qO- http://ipecho.net/plain || { echo "Failed to get public IP address."; exit 1; }
}

get_ip_geolocation() {
    local public_ip=$(get_public_ip)
    echo "YOUR PUBLIC IP IS: $public_ip"
    echo "IP Geolocation Information:"
    curl -s "https://ipinfo.io/$public_ip" || { echo "Failed to get IP geolocation information."; exit 1; }
}

get_hostname() {
    local hostname=$(hostname)
    echo "Hostname: $hostname"
}

get_mac_address() {
    local mac_address=$(ip link show | awk '/ether/ {print $2}' | head -n 1)
    echo "MAC Address: $mac_address"
}

change_hostname() {
    local new_hostname=$1
    if [ -z "$new_hostname" ]; then
        echo "No hostname provided."
        exit 1
    fi
    sudo hostnamectl set-hostname "$new_hostname"
    echo "Hostname changed to: $new_hostname"
}

change_mac_address() {
    local interface=$1
    if [ -z "$interface" ]; then
        echo "No interface provided."
        exit 1
    fi
    sudo ip link set "$interface" down
    sudo macchanger -r "$interface"
    sudo ip link set "$interface" up
    local new_mac=$(ip link show "$interface" | awk '/ether/ {print $2}')
    echo "MAC Address for $interface changed to: $new_mac"
}

perform_dns_leak_test() {
    echo "Performing DNS leak test..."
    curl -s "https://www.dnsleaktest.com" > dns.html

    if [ ! -s dns.html ]; then
        echo "Failed to fetch DNS leak test results."
        rm dns.html
        return 1
    fi

    echo "DNS Leak Test Results:"
    

    ip=$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' dns.html)

    # Extract location
    location=$(grep -oP 'from \K[^<]+' dns.html)

    # Pass IP and location to another Bash script or use them as needed
    echo "IP: $ip"
    echo "Location: $location"

    rm dns.html
}


if [[ $# -eq 0 ]]; then
    get_hostname
    get_mac_address
    get_ip_geolocation
    perform_dns_leak_test
    exit 0
fi

case $1 in
    --help)
        show_help
        exit 0
        ;;
    --change-hostname)
        if [[ -z $2 ]]; then
            echo "Please provide a new hostname."
            exit 1
        fi
        change_hostname "$2"
        exit 0
        ;;
    --change-mac)
        if [[ -z $2 ]]; then
            echo "Please provide a network interface."
            exit 1
        fi
        change_mac_address "$2"
        exit 0
        ;;
    --dns-leak-test)
        perform_dns_leak_test
        exit 0
        ;;
    *)
        show_help
        exit 1
        ;;
esac
