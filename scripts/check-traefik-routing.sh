#!/bin/bash

echo "=== Checking Traefik Routing ==="

# Check Traefik API for routers
echo "Traefik HTTP routers:"
curl -s http://localhost:8080/api/http/routers | jq '.[] | select(.name | contains("dashy")) | {name, rule, service}' 2>/dev/null || {
    echo "jq not available, using plain curl:"
    curl -s http://localhost:8080/api/http/routers | grep -A 5 -B 5 dashy
}

echo ""
echo "Traefik HTTP services:"
curl -s http://localhost:8080/api/http/services | jq '.[] | select(.name | contains("dashy")) | {name, loadBalancer}' 2>/dev/null || {
    echo "jq not available, using plain curl:"
    curl -s http://localhost:8080/api/http/services | grep -A 10 -B 5 dashy
}

echo ""
echo "=== Routing Check Complete ==="
