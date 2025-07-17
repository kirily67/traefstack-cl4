#!/bin/bash

echo "=== Pre-restart Checklist ==="

# Check .env file
echo "1. Checking .env file..."
if grep -q "AUTHELIA_OIDC_HMAC_SECRET" .env && grep -q "AUTHELIA_OIDC_CLIENT_SECRET" .env; then
    echo "✅ OIDC secrets found in .env"
else
    echo "❌ Missing OIDC secrets in .env"
    echo "Add these lines to .env:"
    echo "AUTHELIA_OIDC_HMAC_SECRET=$(openssl rand -base64 32)"
    echo "AUTHELIA_OIDC_CLIENT_SECRET=$(openssl rand -base64 32)"
fi

# Check private key
echo ""
echo "2. Checking RSA private key..."
if [ -f "authelia/oidc_private.pem" ]; then
    echo "✅ RSA private key exists"
    echo "Key size: $(openssl rsa -in authelia/oidc_private.pem -text -noout 2>/dev/null | grep "Private-Key:" | cut -d'(' -f2 | cut -d' ' -f1)bit"
else
    echo "❌ Missing RSA private key"
    echo "Generate with: openssl genrsa -out authelia/oidc_private.pem 4096"
fi

# Check configuration files
echo ""
echo "3. Checking configuration files..."
[ -f "authelia/configuration.yml" ] && echo "✅ authelia/configuration.yml" || echo "❌ authelia/configuration.yml missing"
[ -f "traefik/dynamic/homeassistant.yml" ] && echo "✅ traefik/dynamic/homeassistant.yml" || echo "❌ traefik/dynamic/homeassistant.yml missing"
[ -f "dashy/conf.yml" ] && echo "✅ dashy/conf.yml" || echo "❌ dashy/conf.yml missing"

# Validate YAML syntax
echo ""
echo "4. Validating YAML syntax..."
python3 -c "import yaml; yaml.safe_load(open('authelia/configuration.yml'))" 2>/dev/null && echo "✅ authelia/configuration.yml syntax OK" || echo "❌ authelia/configuration.yml syntax error"
python3 -c "import yaml; yaml.safe_load(open('traefik/dynamic/homeassistant.yml'))" 2>/dev/null && echo "✅ homeassistant.yml syntax OK" || echo "❌ homeassistant.yml syntax error"
python3 -c "import yaml; yaml.safe_load(open('dashy/conf.yml'))" 2>/dev/null && echo "✅ dashy/conf.yml syntax OK" || echo "❌ dashy/conf.yml syntax error"

# Check DNS
echo ""
echo "5. Checking DNS..."
nslookup ha.octopod.eu > /dev/null 2>&1 && echo "✅ ha.octopod.eu resolves" || echo "❌ ha.octopod.eu does not resolve"

echo ""
echo "=== Ready to restart! ==="
