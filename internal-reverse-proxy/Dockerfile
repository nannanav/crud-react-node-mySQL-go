FROM nginx:alpine

# Set up working directory
WORKDIR /etc/nginx

# Copy the Nginx configuration file
COPY nginx.conf /etc/nginx/nginx.conf

# Expose HTTP and HTTPS ports
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
