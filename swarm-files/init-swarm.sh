#!/bin/bash

echo "Initializing Docker Swarm on single node..."

# Инициализация на swarm
docker swarm init

echo "Swarm initialized successfully!"
echo ""
echo "Current node status:"
docker node ls

echo ""
echo "To add worker nodes later, use:"
echo "docker swarm join-token worker"
echo ""
echo "To add manager nodes later, use:"
echo "docker swarm join-token manager"
