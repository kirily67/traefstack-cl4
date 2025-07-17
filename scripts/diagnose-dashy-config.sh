#!/bin/bash

echo "=== Diagnosing Dashy Configuration ==="

# Check if conf.yml exists
echo "Checking dashy/conf.yml file:"
if [ -f "dashy/conf.yml" ]; then
    echo "✅ dashy/conf.yml exists"
    echo "File size: $(ls -lh dashy/conf.yml | awk '{print $5}')"
    echo "Permissions: $(ls -l dashy/conf.yml | awk '{print $1}')"
else
    echo "❌ dashy/conf.yml does not exist"
fi

# Check file content
echo ""
echo "First 10 lines of conf.yml:"
head -10 dashy/conf.yml 2>/dev/null || echo "Cannot read file"

# Check YAML syntax
echo ""
echo "Checking YAML syntax:"
python3 -c "import yaml; yaml.safe_load(open('dashy/conf.yml'))" 2>/dev/null && echo "✅ YAML syntax is valid" || echo "❌ YAML syntax error"

# Check container mount
echo ""
echo "Checking container mount:"
docker compose exec dashy ls -la /app/public/ | grep conf.yml || echo "conf.yml not found in container"

# Check container logs
echo ""
echo "Dashy container logs:"
docker compose logs dashy | tail -10

# Check if container can read the file
echo ""
echo "Testing file access from container:"
docker compose exec dashy cat /app/public/conf.yml | head -5 2>/dev/null || echo "Cannot read config file from container"

echo "=== Diagnosis complete ==="
