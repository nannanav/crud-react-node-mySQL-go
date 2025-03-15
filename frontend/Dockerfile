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

# Build the React app
RUN yarn build

# Use Nginx to serve the build files
FROM nginx:alpine

WORKDIR /usr/share/nginx/html
COPY --from=builder /app/dist .
COPY env.js ./env.js.template

RUN ls -l

# Install gettext for envsubst (needed for variable substitution)
RUN apk add --no-cache gettext

# Expose port 80
EXPOSE 80

# Replace environment variables inside env.js at container start
# CMD envsubst < env.js.template > env.js && nginx -g "daemon off;"
CMD sh -c "echo 'Before envsubst:' && \
    ls -l /usr/share/nginx/html && \
    envsubst < /usr/share/nginx/html/env.js.template > /usr/share/nginx/html/env.js && \
    echo 'After envsubst:' && \
    ls -l /usr/share/nginx/html && \
    cat /usr/share/nginx/html/env.js && \
    nginx -g 'daemon off;'"