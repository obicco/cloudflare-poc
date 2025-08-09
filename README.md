# Cloudflare Tunnel PoC with Authentication

A proof of concept for exposing local applications to the internet using Cloudflare Tunnel with HTTP Basic Authentication.

## What This Project Demonstrates

- **Secure external access** without port forwarding or VPN
- **HTTP Basic Authentication** to protect your services
- **Docker containerization** ready for production
- **Zero configuration** networking through Cloudflare
- **Public monitoring endpoints** for health checks

## Project Structure

```
cloudflare-poc/
├── docker-compose.yml    # Main orchestration file
├── Dockerfile           # Web application container
├── index.html          # Protected dashboard webpage
├── nginx.conf          # Web server configuration with auth
├── manage-users.sh     # User management script
├── run-tunnel.sh       # Quick start script
├── .env.example        # Environment template
├── auth/
│   └── .htpasswd       # Encrypted password file (auto-generated)
└── README.md           # This file
```

## Quick Start

### 1. Setup Authentication
```bash
# Create default users (admin/cloudflare123, demo/demo123)
./manage-users.sh setup
```

### 2. Start the Application
```bash
# Build and start the web application
docker-compose up --build -d
```

### 3. Create Public Tunnel
```bash
# Option A: Use the convenience script
./run-tunnel.sh

# Option B: Manual tunnel creation
docker run --rm --network="host" \
  cloudflare/cloudflared:latest \
  tunnel --url http://localhost:8080
```

### 4. Access Your Application
- **Local**: http://localhost:8080 (requires authentication)
- **Public**: Use the `*.trycloudflare.com` URL from tunnel output
- **Health**: Add `/health` to any URL (public, no auth required)
- **Status**: Add `/status` to any URL (public, no auth required)

## Authentication

### Default Credentials
- **Username**: `admin` | **Password**: `cloudflare123`
- **Username**: `demo` | **Password**: `demo123`

### User Management
```bash
# List current users
./manage-users.sh list

# Add a new user
./manage-users.sh create username password

# Remove all users and start fresh
./manage-users.sh reset

# Recreate default users
./manage-users.sh setup
```

## Security Features

- **HTTP Basic Authentication**: Industry-standard protection
- **Encrypted Passwords**: bcrypt hashing in `.htpasswd` file
- **Selective Protection**: Main app requires auth, monitoring endpoints are public
- **Security Headers**: XSS, clickjacking, and MIME-type protection
- **Cloudflare Protection**: Automatic DDoS protection and SSL/TLS

## Testing

### Test Authentication
```bash
# This will fail (401 Unauthorized)
curl http://localhost:8080

# This will succeed
curl -u admin:cloudflare123 http://localhost:8080

# Public endpoints (no authentication required)
curl http://localhost:8080/health    # Returns: OK
curl http://localhost:8080/status    # Returns: JSON status
```

### Test External Access
1. Start the tunnel with `./run-tunnel.sh`
2. Copy the `*.trycloudflare.com` URL from the output
3. Visit the URL in a browser from any device/network
4. Enter authentication credentials when prompted
5. Verify the dashboard shows your external IP

## Production Setup (Optional)

### With Your Own Domain
1. **Create Cloudflare Account**: Sign up at [cloudflare.com](https://cloudflare.com)
2. **Add Domain**: Add your domain to Cloudflare
3. **Create Named Tunnel**:
   ```bash
   cloudflared tunnel login
   cloudflared tunnel create my-server
   cloudflared tunnel route dns my-server server.yourdomain.com
   ```
4. **Get Tunnel Token**: From Cloudflare dashboard
5. **Update Environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your tunnel token
   ```
4. **Start Production**: `docker-compose up -d`

## Configuration Files Explained

### `docker-compose.yml`
Main orchestration file that builds and runs the web container with port mapping (8080:80).

### `Dockerfile` 
Creates nginx-based container with authentication support, copies HTML content and auth configuration.

### `nginx.conf`
Web server configuration with HTTP Basic Auth enabled, security headers, and public monitoring endpoints.

### `index.html`
Clean, professional dashboard showing connection status, authentication confirmation, and real-time metrics.

### `manage-users.sh`
Script for managing HTTP Basic Auth users - create, list, delete users with encrypted password storage.

### `run-tunnel.sh`
Convenience script that starts the application and creates a Cloudflare tunnel with authentication info.

## Important Notes

- **Passwords**: Never commit `auth/.htpasswd` to version control (already in `.gitignore`)
- **Temporary URLs**: `*.trycloudflare.com` URLs expire when tunnel stops
- **Production**: Use named tunnels with your own domain for permanent deployment
- **Security**: Change default passwords before production use

## Success Indicators

If working correctly, you should see:
- Browser authentication prompt on public URL
- Connection status indicators showing active/secure states
- Real-time metrics and connection details
- Your external IP and geo location displayed
- Public health/status endpoints accessible without auth

## Learn More

- [Cloudflare Tunnel Documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
- [nginx HTTP Basic Auth](https://nginx.org/en/docs/http/ngx_http_auth_basic_module.html)
