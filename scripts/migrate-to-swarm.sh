#!/bin/bash

echo "Do you want to initialize Docker Swarm? (y/n)"
read -r response

if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Initializing Docker Swarm..."
    
    # Get the IP address of the current machine
    IP=$(hostname -I | awk '{print $1}')
    
    # Initialize swarm with specific IP
    docker swarm init --advertise-addr $IP
    
    echo ""
    echo "Swarm initialized successfully!"
    echo "Current node status:"
    docker node ls
    
    echo ""
    echo "To add worker nodes later, run this command on other machines:"
    docker swarm join-token worker
    
    echo ""
    echo "To add manager nodes later, run this command on other machines:"
    docker swarm join-token manager
    
    echo ""
    echo "You can now switch to the Swarm version of docker-compose.yml"
    echo "and use 'docker stack deploy' instead of 'docker-compose up'"
else
    echo "Swarm initialization cancelled."
fi
