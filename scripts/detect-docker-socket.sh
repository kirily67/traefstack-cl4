#!/bin/bash

# Detect Docker socket path for rootless Docker
detect_docker_socket() {
    local possible_sockets=(
        "/user/1000/docker.sock"
        "$HOME/.docker/run/docker.sock"
        "/run/user/$(id -u)/docker.sock"
        "$XDG_RUNTIME_DIR/docker.sock"
    )
    
    for sock in "${possible_sockets[@]}"; do
        if [ -S "$sock" ]; then
            echo "$sock"
            return 0
        fi
    done
    
    return 1
}

DOCKER_SOCK=$(detect_docker_socket)
if [ $? -eq 0 ]; then
    echo "Docker socket detected at: $DOCKER_SOCK"
    export DOCKER_SOCK
else
    echo "ERROR: Docker socket not found"
    exit 1
fi
