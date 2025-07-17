#!/bin/bash

echo "=== Generating OpenID Connect Secrets ==="

# Generate OIDC HMAC secret
OIDC_HMAC_SECRET=$(openssl rand -base64 32)
echo "AUTHELIA_OIDC_HMAC_SECRET=$OIDC_HMAC_SECRET"

# Generate OIDC client secret
OIDC_CLIENT_SECRET=$(openssl rand -base64 32)
echo "AUTHELIA_OIDC_CLIENT_SECRET=$OIDC_CLIENT_SECRET"

# Generate RSA private key
echo "Generating RSA private key..."
openssl genrsa -out authelia/oidc_private.pem 4096

echo ""
echo "✅ Generated secrets. Add these to your .env file:"
echo "AUTHELIA_OIDC_HMAC_SECRET=$OIDC_HMAC_SECRET"
echo "AUTHELIA_OIDC_CLIENT_SECRET=$OIDC_CLIENT_SECRET"
echo ""
echo "📝 Copy the contents of authelia/oidc_private.pem to your authelia configuration"
