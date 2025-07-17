#!/bin/bash

echo "=== Rootless Docker Diagnosis ==="
echo "Date: $(date)"
echo "User: $(whoami)"
echo "UID: $(id -u)"
echo "GID: $(id -g)"
echo ""

# Check if rootless Docker is properly installed
echo "=== Checking rootless Docker installation ==="
if command -v dockerd-rootless.sh &> /dev/null; then
    echo "✅ dockerd-rootless.sh found at: $(which dockerd-rootless.sh)"
else
    echo "❌ dockerd-rootless.sh not found"
fi

if command -v rootlesskit &> /dev/null; then
    echo "✅ rootlesskit found at: $(which rootlesskit)"
else
    echo "❌ rootlesskit not found"
fi

# Check environment variables
echo ""
echo "=== Environment Variables ==="
echo "XDG_RUNTIME_DIR: ${XDG_RUNTIME_DIR:-not set}"
echo "DOCKER_HOST: ${DOCKER_HOST:-not set}"
echo "PATH: $PATH"

# Check runtime directory
echo ""
echo "=== Runtime Directory ==="
if [ -d "/run/user/1000" ]; then
    echo "✅ /run/user/1000 exists"
    echo "Permissions: $(ls -ld /run/user/1000)"
    echo "Contents:"
    ls -la /run/user/1000/ | head -10
else
    echo "❌ /run/user/1000 does not exist"
fi

# Check for existing Docker processes
echo ""
echo "=== Existing Docker Processes ==="
if pgrep -u $(id -u) dockerd > /dev/null; then
    echo "✅ dockerd processes running:"
    pgrep -u $(id -u) -fl dockerd
else
    echo "❌ No dockerd processes running"
fi

if pgrep -u $(id -u) rootlesskit > /dev/null; then
    echo "✅ rootlesskit processes running:"
    pgrep -u $(id -u) -fl rootlesskit
else
    echo "❌ No rootlesskit processes running"
fi

# Check systemd service
echo ""
echo "=== Systemd Service Status ==="
if systemctl --user is-enabled docker.service &>/dev/null; then
    echo "Service enabled: $(systemctl --user is-enabled docker.service)"
else
    echo "Service not enabled or not found"
fi

if systemctl --user is-active docker.service &>/dev/null; then
    echo "Service active: $(systemctl --user is-active docker.service)"
else
    echo "Service not active"
fi

# Check logs
echo ""
echo "=== Recent Docker Logs ==="
journalctl --user -u docker.service --no-pager -n 10

# Check daemon.json
echo ""
echo "=== Daemon Configuration ==="
if [ -f "$HOME/.config/docker/daemon.json" ]; then
    echo "daemon.json exists:"
    cat "$HOME/.config/docker/daemon.json"
else
    echo "No daemon.json found"
fi

# Check for conflicting installations
echo ""
echo "=== Checking for System Docker ==="
if systemctl is-active docker &>/dev/null; then
    echo "⚠️  System Docker is running (might conflict)"
    echo "Status: $(systemctl is-active docker)"
else
    echo "✅ System Docker is not running"
fi

echo ""
echo "=== Diagnosis Complete ==="
