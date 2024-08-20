#!/bin/bash

ip=""

help(){
    echo "Usage: $0 -i IP"
    echo
    echo "Desccripción:"
    echo "- Se hace uso de ipinfo --> Limitado"
    echo "- Se hace uso de lacnic"
    echo
    echo "Opciones:"
    echo "    -h    Show this message"
    echo "    -i    IPv4 o IPv6. Para LACNIC solo IPv4"
}

while getopts "i:h" opt; do
    case $opt in
        (i)
            ip="$OPTARG"
            ;;
        (h)
            help
            exit 0
            ;;
        (\?)
            echo "Usage: $0 -i IPv4/IPv6"
            exit 1
            ;;
    esac
done

if [ -z "$ip" ]; then
    help
    exit 1
fi

if [ -n "$ip" ]; then
    
    response_ipinfo=$(curl -s https://ipinfo.io/widget/demo/$ip)
    response_lacnic=$(curl -s https://rdap.lacnic.net/rdap/whois/$ip)

    if [[ "$response_ipinfo" == *"Too Many Requests"* ]]; then
        echo -e "\e[31m[-] Usando el motor ipinfo.io\e[0m"
        echo "$response_ipinfo"
    else
        echo -e "\e[32m[+] Usando el motor ipinfo.io\e[0m"
        echo "$response_ipinfo" | jq
    fi


    if [[ "$response_lacnic" == *"% No match for"* || "$response_lacnic" == *"Timeout"* ]]; then
        echo -e "\e[31m[-] Usando el motor lacnic.com\e[0m"
        
        if [[ "$response_lacnic" == *"Timeout"* ]]; then
            echo $response_lacnic
        else
            echo "No match for $ip"
        fi

    else
        echo -e "\e[32m[+] Usando el motor lacnic.com\e[0m"
        echo "$response_lacnic" | sed '/^%/d' | awk 'NF' | awk '{ gsub(/^[ \t]+/, "", $0); gsub(/[ \t]+$/, "", $0); print }'
    fi
fi
