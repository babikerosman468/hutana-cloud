#!/data/data/com.termux/files/usr/bin/bash

echo "======================================"
echo "🛑 Stopping Hutana Server & Tunnel..."
echo "======================================"

# Kill Python HTTP server
pkill -f "http.server" 2>/dev/null && echo "✅ Server stopped" || echo "ℹ️ Server not running"

# Kill Cloudflare tunnel
pkill -f "cloudflared tunnel" 2>/dev/null && echo "✅ Tunnel stopped" || echo "ℹ️ Tunnel not running"

# Extra safety
pkill -f cloudflared 2>/dev/null || true

echo "🧹 Cleanup complete"
echo "======================================"

