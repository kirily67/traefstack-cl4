#!/bin/bash

echo "Checking Docker socket permissions for rootless Docker..."

DOCKER_SOCK="/user/1000/docker.sock"

if [ -S "$DOCKER_SOCK" ]; then
    echo "Docker socket found: $DOCKER_SOCK"
    
    # Check current permissions
    echo "Current permissions:"
    ls -la "$DOCKER_SOCK"
    
    # Check if we can access it
    if docker info > /dev/null 2>&1; then
        echo "Docker access: OK ✓"
    else
        echo "Docker access: FAILED ✗"
        echo "Trying to fix permissions..."
        
        # Try to make socket readable by everyone (temporary fix)
        chmod 666 "$DOCKER_SOCK" 2>/dev/null || {
            echo "Cannot change socket permissions. Trying sudo..."
            sudo chmod 666 "$DOCKER_SOCK" 2>/dev/null || {
                echo "Cannot change permissions even with sudo"
                echo "Socket is owned by: $(stat -c '%U:%G' "$DOCKER_SOCK")"
                echo "Current user: $(whoami)"
                echo "Current groups: $(groups)"
            }
        }
    fi
else
    echo "Docker socket not found at: $DOCKER_SOCK"
    echo "Looking for other socket locations..."
    
    find /run/user/1000/ -name "docker.sock" 2>/dev/null || echo "No docker.sock found in /run/user/1000/"
    find /tmp/ -name "docker.sock" 2>/dev/null || echo "No docker.sock found in /tmp/"
fi
