#!/bin/bash

echo "Cloudflare Tunnel PoC with Authentication"
echo "=========================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

echo "Docker is installed"

# Check if auth file exists
if [ ! -f "auth/.htpasswd" ]; then
    echo "Authentication not set up. Running setup..."
    ./manage-users.sh setup
fi

# Use docker compose or docker-compose
if docker compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="docker compose"
else
    COMPOSE_CMD="docker-compose"
fi

echo "Building and starting authenticated web server..."
$COMPOSE_CMD up --build -d

echo ""
echo "Starting Cloudflare Tunnel with Authentication..."
echo "This will create a temporary *.trycloudflare.com URL"
echo ""

# Check if cloudflared is installed
if command -v cloudflared &> /dev/null; then
    echo "Using local cloudflared installation"
    echo "Creating tunnel... (This may take a few seconds)"
    echo ""
    echo "Authentication credentials:"
    echo "   Username: admin"
    echo "   Password: cloudflare123"
    echo "   (or demo/demo123)"
    echo ""
    cloudflared tunnel --url http://localhost:8080
else
    echo "cloudflared not found locally, using Docker..."
    echo ""
    echo "Creating tunnel... (This may take a few seconds)"
    echo "   Press Ctrl+C to stop the tunnel"
    echo ""
    echo "Authentication credentials:"
    echo "   Username: admin"
    echo "   Password: cloudflare123" 
    echo "   (or demo/demo123)"
    echo ""
    docker run --rm --network="host" cloudflare/cloudflared:latest tunnel --url http://localhost:8080
fi
