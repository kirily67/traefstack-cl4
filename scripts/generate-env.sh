#!/bin/bash

echo "Generating .env file with secrets..."

# Generate secrets
JWT_SECRET=$(openssl rand -hex 32)
SESSION_SECRET=$(openssl rand -hex 32)
STORAGE_KEY=$(openssl rand -hex 32)

# Create .env file
cat > .env << EOF
# Authelia Secrets - Generated $(date)
AUTHELIA_JWT_SECRET=$JWT_SECRET
AUTHELIA_SESSION_SECRET=$SESSION_SECRET
AUTHELIA_STORAGE_KEY=$STORAGE_KEY
EOF

echo ".env file created successfully!"
echo ""
echo "Secrets generated:"
echo "JWT Secret: $JWT_SECRET"
echo "Session Secret: $SESSION_SECRET"
echo "Storage Key: $STORAGE_KEY"
echo ""
echo "These secrets are now saved in .env file"
