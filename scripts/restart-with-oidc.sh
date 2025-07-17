#!/bin/bash

echo "=== Restarting with OpenID Connect ==="

# Pre-flight check
./scripts/pre-restart-check.sh

echo ""
echo "Press Enter to proceed with restart..."
read

# Backup current state
echo "Creating backup..."
cp docker-compose.yml docker-compose.yml.backup.$(date +%Y%m%d_%H%M%S)

# Stop services
echo "Stopping services..."
docker compose down

# Wait a moment
sleep 5

# Start services
echo "Starting services..."
docker compose up -d

# Monitor startup
echo "Monitoring startup..."
for i in {1..30}; do
    if docker compose ps | grep -q "Up"; then
        echo "Services starting... ($i/30)"
        sleep 2
    else
        break
    fi
done

# Check status
echo ""
echo "Final status:"
docker compose ps

# Test endpoints
echo ""
echo "Testing endpoints..."
sleep 10
curl -k -s https://auth.octopod.eu/.well-known/openid_configuration > /dev/null 2>&1 && echo "✅ OIDC endpoint working" || echo "❌ OIDC endpoint not working"
curl -k -s https://ha.octopod.eu > /dev/null 2>&1 && echo "✅ Home Assistant accessible" || echo "❌ Home Assistant not accessible"

echo ""
echo "=== Restart Complete ==="
echo "🏠 Home Assistant: https://ha.octopod.eu"
echo "🔐 Check logs: docker-compose logs authelia"
