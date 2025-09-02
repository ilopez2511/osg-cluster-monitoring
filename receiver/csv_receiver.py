# receiver/csv_receiver.py

import socket
import os

HOST = '0.0.0.0'
PORT = 9999
DATA_DIR = os.environ.get("DATA_DIR", "./data")

print(f"[Receiver] Listening on port {PORT}...")
print(f"[Receiver] Writing files to {DATA_DIR}...\n")

os.makedirs(DATA_DIR, exist_ok=True)

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()

    while True:
        conn, addr = s.accept()
        with conn:
            print(f"[Receiver] Connection from {addr}")
            data = b""

            while True:
                chunk = conn.recv(4096)
                if not chunk:
                    break
                data += chunk

            if data:
                parts = data.decode(errors="ignore").split('\n')

                if parts[0].startswith("FILE:"):
                    relpath = parts[0].replace("FILE:", "").strip()
                    lines = '\n'.join(parts[1:]).strip()

                    if lines:
                        full_path = os.path.join(DATA_DIR, relpath)
                        os.makedirs(os.path.dirname(full_path), exist_ok=True)

                        with open(full_path, "a") as f:
                            f.write(lines + "\n")
                            
                        line_count = len(lines.splitlines())
                        print(f"[Receiver] Wrote {line_count} line(s) to {full_path}\n")
