#!/bin/bash
# stopall.sh - Stop all Python web servers

echo "Stopping all Python web servers..."
pkill -f "python.*http.server" && echo "All web servers stopped" || echo "No web servers were running"
