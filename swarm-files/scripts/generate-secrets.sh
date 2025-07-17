#!/bin/bash

echo "Generating secrets for Authelia..."

# Generate JWT secret
JWT_SECRET=$(openssl rand -hex 32)
echo "$JWT_SECRET" | docker secret create authelia_jwt_secret -

# Generate session secret
SESSION_SECRET=$(openssl rand -hex 32)
echo "$SESSION_SECRET" | docker secret create authelia_session_secret -

# Generate storage encryption key
STORAGE_KEY=$(openssl rand -hex 32)
echo "$STORAGE_KEY" | docker secret create authelia_storage_key -

echo "Secrets generated successfully!"
echo "JWT Secret: $JWT_SECRET"
echo "Session Secret: $SESSION_SECRET"
echo "Storage Key: $STORAGE_KEY"
echo ""
echo "Save these secrets securely!"
