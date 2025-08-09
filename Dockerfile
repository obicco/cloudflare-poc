# Use nginx to serve the static website with authentication
FROM nginx:alpine

# Copy the HTML file to nginx's default directory
COPY index.html /usr/share/nginx/html/

# Copy nginx configuration with authentication
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy authentication files
COPY auth/.htpasswd /etc/nginx/auth/.htpasswd

# Create auth directory and set permissions
RUN mkdir -p /etc/nginx/auth && \
    chown -R nginx:nginx /etc/nginx/auth && \
    chmod 644 /etc/nginx/auth/.htpasswd

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
