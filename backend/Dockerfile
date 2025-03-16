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

COPY wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

# Expose the port the backend runs on
EXPOSE 8800

# Start the backend server
# CMD ["sh", "-c", "/wait-for-it.sh database:3306 -- npm start"]
# CMD ["sh", "-c", "/wait-for-it.sh \"$DB_HOST\":\"$DB_PORT\" -- npm start"]
CMD ["npm", "start"]
