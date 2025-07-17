#!/bin/bash

echo "=== Fixing Docker systemd service configuration ==="

# Stop the service
echo "Stopping Docker service..."
systemctl --user stop docker.service

# Wait for it to stop
sleep 5

# Backup current service file
cp ~/.config/systemd/user/docker.service ~/.config/systemd/user/docker.service.backup

# Create corrected service file
cat > ~/.config/systemd/user/docker.service << 'EOF'
[Unit]
Description=Docker Application Container Engine (Rootless)
Documentation=https://docs.docker.com/go/rootless/
After=network.target

[Service]
Type=exec
ExecStart=/usr/bin/dockerd-rootless.sh --host unix:///run/user/1000/docker.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=mixed
Environment=XDG_RUNTIME_DIR=/run/user/1000

[Install]
WantedBy=default.target
EOF

# Reload systemd
echo "Reloading systemd..."
systemctl --user daemon-reload

# Start the service
echo "Starting Docker service..."
systemctl --user start docker.service

# Wait a bit for startup
sleep 10

# Check status
echo "Checking service status..."
if systemctl --user is-active docker.service &>/dev/null; then
    echo "✅ Docker service is now active!"
    echo "Status: $(systemctl --user is-active docker.service)"
else
    echo "❌ Docker service is still not active"
    echo "Status: $(systemctl --user is-active docker.service)"
    echo "Full status:"
    systemctl --user status docker.service --no-pager -l
fi

# Test Docker
echo "Testing Docker..."
if docker info > /dev/null 2>&1; then
    echo "✅ Docker is working!"
else
    echo "❌ Docker is not working"
fi

echo "=== Service fix completed ==="
