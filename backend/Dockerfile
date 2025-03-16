# Use a lightweight Node.js image
FROM node:18-alpine

RUN apk add --no-cache bash

# Set working directory
WORKDIR /app

# Copy package.json and install dependencies
COPY package.json package-lock.json ./
RUN npm install

RUN npm install -g nodemon

# Copy the rest of the application files
COPY . .

# Expose the port the backend runs on
EXPOSE 8800

# Start the backend server
CMD ["npm", "start"]
