#!/usr/bin/env python3

import socket
import struct
import time

def query_bedrock_server(ip, port):
    OFFLINE_MESSAGE_DATA_ID = b'\x00\xff\xff\x00\xfe\xfe\xfe\xfe\xfd\xfd\xfd\xfd\x12\x34\x56\x78'

    timestamp = int(time.time() * 1000) & 0xFFFFFFFFFFFFFFFF
    request = b'\x01' + struct.pack('>Q', timestamp) + OFFLINE_MESSAGE_DATA_ID + struct.pack('>Q', 2)

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(3)

    try:
        sock.sendto(request, (ip, port))
        data, _ = sock.recvfrom(4096)

        if not data.startswith(b'\x1c'):
            raise ValueError("La réponse reçue n'est pas un PONG valide.")

        if data[17:33] != OFFLINE_MESSAGE_DATA_ID:
            raise ValueError("Les magic bytes ne correspondent pas.")

        response = data[35:].decode('utf-8').split(';')
        return {
            'GameName': response[0] if len(response) > 0 else None,
            'HostName': response[1] if len(response) > 1 else None,
            'Protocol': response[2] if len(response) > 2 else None,
            'Version': response[3] if len(response) > 3 else None,
            'Players': int(response[4]) if len(response) > 4 else 0,
            'MaxPlayers': int(response[5]) if len(response) > 5 else 0,
            'ServerId': response[6] if len(response) > 6 else None,
            'Map': response[7] if len(response) > 7 else None,
            'GameMode': response[8] if len(response) > 8 else None,
            'NintendoLimited': response[9] if len(response) > 9 else None,
            'IPv4Port': int(response[10]) if len(response) > 10 else 0,
            'IPv6Port': int(response[11]) if len(response) > 11 else 0,
            'Extra': response[12] if len(response) > 12 else None,
        }

    except socket.timeout:
        return {"error": "Aucune réponse du serveur."}
    except Exception as e:
        return {"error": str(e)}
    finally:
        sock.close()

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 3:
        print("Usage: query_bedrock.py <IP> <PORT>")
        sys.exit(1)
    ip = sys.argv[1]
    port = int(sys.argv[2])
    print(query_bedrock_server(ip, port))
