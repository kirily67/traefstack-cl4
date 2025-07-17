#!/bin/bash

echo "=== Preparing Authelia files ==="

# Create authelia directory with proper permissions
mkdir -p authelia
chmod 755 authelia

# Create users database
echo "Creating users database..."
cat > authelia/users_database.yml << 'EOF'
users:
  kirily67:
    displayname: "Kirily67"
    password: "$argon2id$v=19$m=65536,t=3,p=4$BpLnfgDsc2WD8F2q$o/vzA4myCqZZ36bUGkQqE/qUxSFCqFhzPw3p4lHcKhE="  # changeme
    email: kirily67@yourdomain.com
    groups:
      - admins
      - dev
EOF

# Create empty SQLite database file
echo "Creating empty SQLite database..."
touch authelia/db.sqlite3
chmod 666 authelia/db.sqlite3

# Create empty notification file
echo "Creating notification file..."
touch authelia/notification.txt
chmod 666 authelia/notification.txt

# Set proper permissions for entire directory
chmod -R 755 authelia/
chmod 666 authelia/db.sqlite3
chmod 666 authelia/notification.txt

echo "Files created:"
ls -la authelia/

echo "=== Authelia files prepared ==="
