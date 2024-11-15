#!/bin/bash

IP_RANGE="{1..255}.{1..255}.{1..255}.{1..255}"
PORT_MCPE_RANGE="19000-20000"
PORT_JAVA_RANGE="25565-25575"

mode="mcpe"
output_file="servers_found.txt"

check_server() {
    local ip=$1
    local port=$2
    local mode=$3

    if [[ "$mode" == "mcpe" ]]; then
        #UDP
        echo -e "\x01" | nc -u -w 1 "$ip" "$port" > /tmp/mcpe_response 2>/dev/null

        if grep -q "MCPE" /tmp/mcpe_response; then
            echo "Serveur Minecraft Bedrock trouvé sur l'IP $ip, port UDP $port"
            echo "$ip:$port (MCPE)" >> "$output_file"
        fi
    fi
}

for ip in $(eval echo $IP_RANGE); do
    if [[ "$mode" == "mcpe" ]]; then
        for port in $(seq ${PORT_MCPE_RANGE/-/ }); do
            echo "Vérification de l'IP $ip, port UDP $port"
            check_server "$ip" "$port" "mcpe"
        done
    fi
done

rm -f /tmp/mcpe_response #/tmp/java_response
