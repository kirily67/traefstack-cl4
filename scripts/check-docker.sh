#!/bin/bash

echo "Checking Docker configuration..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Cannot connect to Docker daemon"
    echo "Possible solutions:"
    echo "1. Start Docker daemon: sudo systemctl start docker"
    echo "2. Add user to docker group: sudo usermod -aG docker $USER"
    echo "3. Restart Docker service: sudo systemctl restart docker"
    exit 1
fi

echo "Docker daemon is running ✓"

# Check user permissions
if groups $USER | grep -q '\bdocker\b'; then
    echo "User $USER is in docker group ✓"
else
    echo "WARNING: User $USER is NOT in docker group"
    echo "Run: sudo usermod -aG docker $USER"
    echo "Then logout and login again"
fi

# Check Docker socket
ls -la /var/run/docker.sock

echo ""
echo "Docker check completed!"
