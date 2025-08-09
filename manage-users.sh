#!/bin/bash

echo "Cloudflare Tunnel PoC - Authentication Setup"
echo "============================================="

# Ensure auth directory exists
mkdir -p auth

# Function to create/update user
create_user() {
    local username="$1"
    local password="$2"
    
    if [ -z "$username" ] || [ -z "$password" ]; then
        echo "Username and password are required"
        return 1
    fi
    
    echo "Creating user '$username'..."
    docker run --rm httpd:2.4-alpine htpasswd -nbB "$username" "$password" >> auth/.htpasswd
    echo "User '$username' created successfully"
}

# Function to reset auth file
reset_auth() {
    echo "Resetting authentication file..."
    rm -f auth/.htpasswd
    touch auth/.htpasswd
    echo "Authentication file reset"
}

# Function to list users
list_users() {
    echo "Current users:"
    if [ -f auth/.htpasswd ]; then
        cut -d: -f1 auth/.htpasswd | sed 's/^/  - /'
    else
        echo "  (no users found)"
    fi
}

# Main menu
case "$1" in
    "create")
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Usage: $0 create <username> <password>"
            exit 1
        fi
        create_user "$2" "$3"
        ;;
    "reset")
        reset_auth
        ;;
    "list")
        list_users
        ;;
    "setup")
        echo "Setting up default authentication..."
        reset_auth
        create_user "admin" "cloudflare123"
        create_user "demo" "demo123"
        echo ""
        echo "Default users created:"
        echo "  Username: admin | Password: cloudflare123"
        echo "  Username: demo  | Password: demo123"
        ;;
    *)
        echo "Usage: $0 {setup|create|reset|list}"
        echo ""
        echo "Commands:"
        echo "  setup                    - Create default users (admin/demo)"
        echo "  create <user> <pass>     - Add a new user"
        echo "  reset                    - Remove all users"
        echo "  list                     - Show current users"
        echo ""
        echo "Examples:"
        echo "  $0 setup"
        echo "  $0 create alice mypassword"
        echo "  $0 list"
        exit 1
        ;;
esac
