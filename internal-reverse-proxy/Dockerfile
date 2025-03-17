FROM nginx:alpine

# Set up working directory
WORKDIR /etc/nginx

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose HTTP port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
