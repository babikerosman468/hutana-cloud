#!/bin/bash

# simpleweb.sh - Simple web server that finds an available port and opens index.html
# Usage: ./simpleweb.sh [DIRECTORY]

DIRECTORY=${1:-$(pwd)}
BASE_PORT=8080
PORT=$BASE_PORT

echo "Starting web server in: $DIRECTORY"

# Find an available port
while netstat -tuln 2>/dev/null | grep -q ":$PORT "; do
    echo "Port $PORT is in use, trying next port..."
    ((PORT++))

    # Safety check to prevent infinite loop
    if [ $PORT -gt 9000 ]; then
        echo "Error: Could not find an available port (tried up to 9000)"
        exit 1
    fi
done

cd "$DIRECTORY" || exit
echo "Server starting on: http://localhost:$PORT"

# Start the web server in the background
python3 -m http.server $PORT &
SERVER_PID=$!

# Wait a moment for the server to start
sleep 2

# Check if server is running
if ps -p $SERVER_PID > /dev/null; then
    echo "Web server started successfully with PID: $SERVER_PID"
    
    # Open index.html in the default browser
    if command -v termux-open >/dev/null 2>&1; then
        echo "Opening http://localhost:$PORT/index.html in browser..."
        termux-open "http://localhost:$PORT/index.html"
    else
        echo "termux-open not available. Please open manually: http://localhost:$PORT/index.html"
    fi
    
    # Wait for server to finish (when user presses Ctrl+C)
    echo "Press Ctrl+C to stop the server"
    wait $SERVER_PID
else
    echo "Failed to start web server"
    exit 1
fi


