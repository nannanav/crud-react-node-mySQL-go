#!/bin/bash
set -e
# Run Docker Compose with build
docker-compose up --build -d

# Check if the command succeeded
if [ $? -eq 0 ]; then
    echo "Docker Compose ran successfully."
    exit 0
else
    echo "Docker Compose failed."
    exit 1
fi