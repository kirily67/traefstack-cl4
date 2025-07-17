#!/bin/bash

echo "Diagnosing Docker socket issue..."

# Check what's at /user/1000/docker.sock
if [ -d "/user/1000/docker.sock" ]; then
    echo "❌ /user/1000/docker.sock is a DIRECTORY (should be a socket file)"
    echo "Contents:"
    ls -la /user/1000/docker.sock/
elif [ -S "/user/1000/docker.sock" ]; then
    echo "✅ /user/1000/docker.sock is a SOCKET (correct)"
    ls -la /user/1000/docker.sock
elif [ -f "/user/1000/docker.sock" ]; then
    echo "❌ /user/1000/docker.sock is a regular FILE (should be a socket)"
    ls -la /user/1000/docker.sock
else
    echo "❌ /user/1000/docker.sock does not exist"
fi

echo ""
echo "Looking for correct Docker socket locations..."

# Common rootless Docker socket locations
POSSIBLE_SOCKETS=(
    "/run/user/1000/docker.sock"
    "$HOME/.docker/run/docker.sock"
    "/tmp/docker-$USER/docker.sock"
    "$XDG_RUNTIME_DIR/docker.sock"
)

FOUND_SOCKET=""
for sock in "${POSSIBLE_SOCKETS[@]}"; do
    if [ -S "$sock" ]; then
        echo "✅ Found socket at: $sock"
        FOUND_SOCKET="$sock"
        ls -la "$sock"
        break
    elif [ -e "$sock" ]; then
        echo "❌ Found non-socket at: $sock"
        ls -la "$sock"
    fi
done

if [ -z "$FOUND_SOCKET" ]; then
    echo "❌ No Docker socket found in standard locations"
    echo ""
    echo "Checking if Docker daemon is running..."
    if systemctl --user is-active docker > /dev/null 2>&1; then
        echo "✅ Docker user service is running"
    else
        echo "❌ Docker user service is not running"
    fi
else
    echo ""
    echo "✅ Correct socket found at: $FOUND_SOCKET"
fi

echo ""
echo "Docker environment variables:"
echo "DOCKER_HOST: ${DOCKER_HOST:-not set}"
echo "XDG_RUNTIME_DIR: ${XDG_RUNTIME_DIR:-not set}"
