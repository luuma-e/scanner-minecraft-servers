#!/bin/bash

generate_ips() {
    local ip_start=$1
    local ip_end=$2
    IFS=. read -r i1 i2 i3 i4 <<<"$ip_start"
    IFS=. read -r e1 e2 e3 e4 <<<"$ip_end"

    for i in $(seq $i1 $e1); do
        for j in $(seq $i2 $e2); do
            for k in $(seq $i3 $e3); do
                for l in $(seq $i4 $e4); do
                    echo "$i.$j.$k.$l"
                done
            done
        done
    done
}

IP_START="100.10.1.0"
IP_END="255.255.255.255"
PORT_MCPE_START=19132
PORT_MCPE_END=19132
output_file="servers_found.txt"

> "$output_file"

check_server() {
    local ip=$1
    local port=$2

    echo "Vérification de $ip:$port"

    result=$(python3 query_bedrock.py "$ip" "$port")
    if echo "$result" | grep -q "MCPE"; then
        echo "Serveur Minecraft Bedrock trouvé : $ip:$port"
        echo "$ip:$port (MCPE)" >> "$output_file"
    fi
}

export -f check_server
export output_file

# Générer les IPs et effectuer les vérifications
generate_ips "$IP_START" "$IP_END" | parallel -j 10000 'for port in $(seq '"$PORT_MCPE_START"' '"$PORT_MCPE_END"'); do check_server {} $port; done'

trap "echo 'Interrompu'; exit" SIGINT SIGTERM
