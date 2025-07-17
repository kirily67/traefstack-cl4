#!/bin/bash

echo "Preparing required files and directories..."

# Create traefik directory
mkdir -p traefik

# Create acme.json file with correct permissions
touch traefik/acme.json
chmod 600 traefik/acme.json

echo "Created traefik/acme.json with 600 permissions"

# Check Docker socket permissions
if [ -S /var/run/docker.sock ]; then
    echo "Docker socket found at /var/run/docker.sock"
    ls -la /var/run/docker.sock
    
    # Check if current user is in docker group
    if groups $USER | grep -q '\bdocker\b'; then
        echo "User $USER is in docker group ✓"
    else
        echo "WARNING: User $USER is NOT in docker group"
        echo "Add user to docker group with: sudo usermod -aG docker $USER"
        echo "Then logout and login again"
    fi
else
    echo "ERROR: Docker socket not found at /var/run/docker.sock"
    echo "Is Docker daemon running?"
fi

echo ""
echo "File preparation completed!"
