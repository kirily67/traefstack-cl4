#!/bin/bash

echo "=== Generating Correct OIDC Secrets ==="

# Generate plain text client secret
PLAIN_SECRET=$(openssl rand -base64 32)
echo "Plain secret: $PLAIN_SECRET"

# Generate hashed client secret using docker
echo "Generating hashed client secret..."
HASHED_SECRET=$(docker run --rm authelia/authelia:latest authelia crypto hash generate pbkdf2 --password="$PLAIN_SECRET" --variant=sha512 --iterations=310000)

echo ""
echo "✅ Generated secrets:"
echo "AUTHELIA_OIDC_CLIENT_SECRET_PLAIN=$PLAIN_SECRET"
echo "AUTHELIA_OIDC_CLIENT_SECRET_HASH=$HASHED_SECRET"
echo ""
echo "📝 Add to .env file:"
echo "AUTHELIA_OIDC_CLIENT_SECRET_PLAIN=$PLAIN_SECRET"
echo "AUTHELIA_OIDC_CLIENT_SECRET_HASH=$HASHED_SECRET"
echo ""
echo "🏠 Use PLAIN secret in Home Assistant configuration"
echo "🔐 Use HASH secret in Authelia configuration"
