#!/bin/bash

echo "Enter password for user :"
read -s password

echo "Generating password hash..."
hash=$(docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password "$password" | grep -o '\$argon2id\$[^"]*')

echo ""
echo "Password hash generated:"
echo "$hash"
echo ""
echo "Copy this hash and paste it in authelia/users_database.yml"
echo "Replace YOUR_PASSWORD_HASH_HERE with the hash above"
