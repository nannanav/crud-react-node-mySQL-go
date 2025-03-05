# Use a lightweight Node.js image
# FROM node:18-alpine
FROM node:18 AS builder

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json yarn.lock ./
RUN yarn install

# Copy the rest of the application files
COPY . .
COPY ../.env .env

# Build the React app
RUN yarn build

# Use Nginx to serve the build files
FROM nginx:alpine
# COPY --from=0 /app/build /usr/share/nginx/html
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]