#!/bin/bash

echo "=== Diagnosing Bad Gateway Issue ==="
echo "Date: $(date)"
echo "Domain: octopod.eu"
echo ""

# Check if all containers are running
echo "=== Container Status ==="
docker compose ps

echo ""
echo "=== Network Status ==="
docker network ls | grep traefik

echo ""
echo "=== Checking Dashy container specifically ==="
if docker compose ps dashy | grep -q "Up"; then
    echo "✅ Dashy container is running"
    
    # Check if Dashy is responding internally
    echo "Testing Dashy internal connectivity..."
    docker compose exec traefik wget -qO- http://dashy:80 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ Traefik can reach Dashy internally"
    else
        echo "❌ Traefik cannot reach Dashy internally"
    fi
    
    # Check Dashy logs
    echo ""
    echo "=== Dashy Logs ==="
    docker compose logs --tail=10 dashy
    
else
    echo "❌ Dashy container is not running"
fi

echo ""
echo "=== Traefik Configuration ==="
# Check if Traefik sees the Dashy service
docker compose exec traefik wget -qO- http://localhost:8080/api/http/routers | grep -i dashy

echo ""
echo "=== Traefik Logs for Dashy ==="
docker compose logs traefik | grep -i dashy | tail -10

echo ""
echo "=== Network Connectivity Test ==="
# Check if containers are on the same network
echo "Traefik networks:"
docker inspect traefik | grep -A 10 '"Networks"'

echo ""
echo "Dashy networks:"
docker inspect dashy | grep -A 10 '"Networks"'

echo ""
echo "=== DNS Resolution Test ==="
# Test DNS resolution within containers
echo "Testing DNS resolution from Traefik container:"
docker compose exec traefik nslookup dashy 2>/dev/null || echo "nslookup not available"
docker compose exec traefik ping -c 1 dashy 2>/dev/null || echo "ping not available"

echo ""
echo "=== Port Check ==="
# Check if Dashy is listening on port 80
docker compose exec dashy netstat -tlnp 2>/dev/null | grep :80 || echo "netstat not available"

echo "=== Diagnosis Complete ==="
