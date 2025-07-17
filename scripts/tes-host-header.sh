#!/bin/bash

echo "=== Testing Host Header Issues ==="

# Test direct access
echo "1. Testing direct access:"
curl -I http://10.11.12.8:8123

# Test with correct host header
echo ""
echo "2. Testing with ha.octopod.eu host header:"
curl -I -H "Host: ha.octopod.eu" http://10.11.12.8:8123

# Test through Traefik
echo ""
echo "3. Testing through Traefik:"
curl -I https://ha.octopod.eu
