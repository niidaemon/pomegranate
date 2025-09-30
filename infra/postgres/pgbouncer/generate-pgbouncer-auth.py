#!/usr/bin/env python3
"""
===================================================================
generate-pgbouncer-auth.py
===================================================================
Purpose:
    Generate SCRAM-SHA-256 password hashes for PgBouncer userlist.txt

Usage:
    python3 generate-pgbouncer-auth.py <username> <password>

Output:
    Prints a line in the format:
    "username" "SCRAM-SHA-256$<salt>$<stored_key>:<server_key>"
===================================================================
"""

import os
import sys
import base64
import hashlib
import hmac

ITERATIONS = 4096

def hi(password: bytes, salt: bytes, iterations: int) -> bytes:
    """PBKDF2-HMAC-SHA-256"""
    return hashlib.pbkdf2_hmac("sha256", password, salt, iterations)

def scram_sha256(password: str):
    salt = os.urandom(16)
    salted_password = hi(password.encode("utf-8"), salt, ITERATIONS)

    client_key = hmac.new(salted_password, b"Client Key", hashlib.sha256).digest()
    stored_key = hashlib.sha256(client_key).digest()
    server_key = hmac.new(salted_password, b"Server Key", hashlib.sha256).digest()

    return (
        base64.b64encode(salt).decode("utf-8"),
        base64.b64encode(stored_key).decode("utf-8"),
        base64.b64encode(server_key).decode("utf-8"),
    )

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 generate-pgbouncer-auth.py <username> <password>")
        sys.exit(1)

    username, password = sys.argv[1], sys.argv[2]
    salt, stored_key, server_key = scram_sha256(password)

    # Format: SCRAM-SHA-256$<iterations>:<salt>$<stored_key>:<server_key>
    hash_str = f"SCRAM-SHA-256${ITERATIONS}:{salt}${stored_key}:{server_key}"
    print(f"\"{username}\" \"{hash_str}\"")

if __name__ == "__main__":
    main()
