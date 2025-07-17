#!/bin/bash

echo "=== Fixing Docker lock conflict ==="

# Stop systemd service
echo "Stopping systemd service..."
systemctl --user stop docker.service 2>/dev/null || true

# Kill existing Docker processes
echo "Killing existing Docker processes..."
pkill -u $(id -u) dockerd 2>/dev/null || true
pkill -u $(id -u) rootlesskit 2>/dev/null || true

# Wait for processes to stop
sleep 5

# Remove lock files and state directory
echo "Removing lock files..."
rm -rf /run/user/1000/dockerd-rootless/lock 2>/dev/null || true
rm -rf /run/user/1000/dockerd-rootless/ 2>/dev/null || true
rm -rf /run/user/1000/docker* 2>/dev/null || true

# Clean up any remaining sockets
echo "Cleaning up sockets..."
rm -f /run/user/1000/docker.sock 2>/dev/null || true

echo "Lock cleanup completed!"
