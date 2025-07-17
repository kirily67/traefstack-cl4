#!/bin/bash

echo "Fixing Docker daemon configuration..."

# Check if daemon.json exists
DAEMON_CONFIG="$HOME/.config/docker/daemon.json"

if [ -f "$DAEMON_CONFIG" ]; then
    echo "Found daemon.json at: $DAEMON_CONFIG"
    echo "Current content:"
    cat "$DAEMON_CONFIG"
    
    # Backup original
    cp "$DAEMON_CONFIG" "$DAEMON_CONFIG.backup"
    
    # Remove experimental flag or create minimal config
    echo '{
  "experimental": false,
  "features": {
    "buildkit": true
  }
}' > "$DAEMON_CONFIG"
    
    echo "Updated daemon.json"
else
    echo "Creating daemon.json..."
    mkdir -p "$HOME/.config/docker"
    echo '{
  "experimental": false,
  "features": {
    "buildkit": true
  }
}' > "$DAEMON_CONFIG"
fi

echo "Daemon configuration fixed!"
