#!/bin/bash

# simpleweb.sh - Simple web server that finds an available port and opens index.html
# Usage: simpleweb [DIRECTORY]

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

    # Generate a unique timestamp to force fresh load
    TIMESTAMP=$(date +%s)
    URLS=(
        "http://localhost:$PORT/index.html?t=$TIMESTAMP"
        "http://127.0.0.1:$PORT/index.html?t=$TIMESTAMP"
        "http://[::1]:$PORT/index.html?t=$TIMESTAMP"
    )

    # Open index.html in the default browser
    if command -v xdg-open >/dev/null 2>&1; then
        # Linux systems - try multiple URLs
        echo "Opening browser with fresh page..."
        for url in "${URLS[@]}"; do
            if curl --silent --head --fail "${url%\\?*}" >/dev/null 2>&1; then
                xdg-open "$url" >/dev/null 2>&1 &
                echo "Opened: ${url%\?*}"
                break
            fi
        done
    elif command -v open >/dev/null 2>&1; then
        # macOS systems
        echo "Opening fresh page in browser..."
        open "http://localhost:$PORT/index.html?t=$TIMESTAMP" >/dev/null 2>&1
    elif command -v termux-open >/dev/null 2>&1; then
        # Termux (Android) - close previous tabs first if possible
        echo "Opening fresh page in browser..."
        termux-open "http://localhost:$PORT/index.html?t=$TIMESTAMP"
    else
        echo "Browser opener not available. Please try these URLs:"
        printf "  - %s\n" "${URLS[@]%\\?*}"
    fi

    # Show all possible URLs
    echo "Server is accessible at:"
    echo "  - http://localhost:$PORT"
    echo "  - http://127.0.0.1:$PORT" 
    echo "  - http://[::1]:$PORT"
    echo ""
    echo "Note: Added timestamp parameter to prevent browser caching"

    # Set up cleanup on script exit
    cleanup() {
        echo "Stopping web server (PID: $SERVER_PID)..."
        kill $SERVER_PID 2>/dev/null
        exit 0
    }
    trap cleanup INT TERM EXIT

    # Wait for server to finish
    echo "Press Ctrl+C to stop the server"
    wait $SERVER_PID
else
    echo "Failed to start web server"
    exit 1
fi
