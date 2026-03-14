
#!/data/data/com.termux/files/usr/bin/bash
set -e  # Exit immediately on any error

########################################
# Hutana Fast Preview – Bulletproof Version
# Combines Hutana.sh + Workflow.sh safely
########################################

# ===== Configurable Settings =====
PORT=8000
BASE="$HOME/hutana_project"
INCOMING="$HOME/downloads/hutana"
VIDEOS="$BASE/videos"
COMPRESSED="$BASE/compressed"
PUBLIC="$BASE/public"
PUBLIC_VIDEOS="$PUBLIC/videos"
LOGS="$BASE/logs"
TOTAL_MINUTES=45
RETENTION_DAYS=1

# ===== Ensure directories exist =====
mkdir -p "$VIDEOS" "$COMPRESSED" "$PUBLIC" "$PUBLIC_VIDEOS" "$LOGS"

# ===== Logging helper =====
function log() {
    echo -e "[`date +'%Y-%m-%d %H:%M:%S'`] $1"
}

# ===== Build HTML gallery =====
function build_gallery() {
    log "🖼️ Building gallery..."
    GALLERY="$PUBLIC/index.html"
    cat > "$GALLERY" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Hutana Fast Preview</title>
<style>
body { font-family: Arial; background:#111; color:#fff; text-align:center; }
video { width:90%; max-width:640px; margin:25px auto; display:block; border-radius:12px; }
h1 { color:#00ff00; }
p { color:#aaa; }
a { color:#00aaff; word-break: break-all; }
hr { border: 1px solid #444; margin: 40px 0; }
</style>
</head>
<body>
<h1>⚡ Hutana Fast Preview</h1>
<p>No compression, minimal CPU use</p>
EOF

    shopt -s nullglob
    files=("$PUBLIC_VIDEOS"/*.mp4)
    if [ ${#files[@]} -eq 0 ]; then
        log "⚠️ No videos in public folder yet"
        echo "<p>No videos available.</p>" >> "$GALLERY"
    else
        for f in "${files[@]}"; do
            name=$(basename "$f")
            url_name=$(echo "$name" | sed 's/ /%20/g')
            echo "<video controls src=\"videos/$url_name\"></video>" >> "$GALLERY"
        done
    fi
    shopt -u nullglob

    cat >> "$GALLERY" <<'EOF'
<hr>
<h2>🎵 Optional Music</h2>
<p>Enjoy the original track from YouTube:</p>
<a href="https://youtu.be/3gSg4tBPZcA?si=ODGGNQcBycPmdK0R" target="_blank">
https://youtu.be/3gSg4tBPZcA?si=ODGGNQcBycPmdK0R
</a>
</body>
</html>
EOF
}

# ===== Sync Videos =====
function sync_videos() {
    shopt -s nullglob
    INCOMING_FILES=("$INCOMING"/*.mp4)
    if [ ${#INCOMING_FILES[@]} -eq 0 ]; then
        log "⚠️ No new videos found in $INCOMING"
    else
        for f in "${INCOMING_FILES[@]}"; do
            name=$(basename "$f")
            safe_name="${name// /_}"
            log "➡️ Moving $name -> $safe_name"
            mv "$f" "$VIDEOS/$safe_name"
            cp "$VIDEOS/$safe_name" "$COMPRESSED/$safe_name"
        done
    fi
    shopt -u nullglob

    # Auto-populate COMPRESSED from VIDEOS if empty
    shopt -s nullglob
    COMP_FILES=("$COMPRESSED"/*.mp4)
    if [ ${#COMP_FILES[@]} -eq 0 ]; then
        log "⚠️ Compressed folder empty, copying from VIDEOS..."
        for f in "$VIDEOS"/*.mp4; do
            cp "$f" "$COMPRESSED/"
        done
    fi
    shopt -u nullglob

    # Copy to PUBLIC/videos
    shopt -s nullglob
    for f in "$COMPRESSED"/*.mp4; do
        cp "$f" "$PUBLIC_VIDEOS/"
    done
    shopt -u nullglob
}

# ===== Start Workflow =====
function start_workflow() {
    log "⚡ Starting Hutana Fast Preview Workflow..."
    stop_workflow

    sync_videos
    build_gallery

    # Start Python server
    log "🚀 Starting local server on port $PORT..."
    cd "$PUBLIC"
    pkill -f "http.server $PORT" 2>/dev/null || true
    python3 -m http.server "$PORT" >"$LOGS/server.log" 2>&1 &
    SERVER_PID=$!
    sleep 2
    LOCAL_URL="http://localhost:$PORT/"
    log "🌐 Local preview live: $LOCAL_URL"
    termux-open-url "$LOCAL_URL"

    # Start Cloudflare tunnel
    log "🌐 Launching Cloudflare tunnel..."
    LOG_FILE=$(mktemp)
    cloudflared tunnel --url "http://localhost:$PORT" > "$LOG_FILE" 2>&1 &
    TUNNEL_PID=$!

    CLOUDFLARE_URL=""
    for i in {1..20}; do
        sleep 1
        CLOUDFLARE_URL=$(grep -oE 'https://[a-z0-9.-]+\.trycloudflare\.com' "$LOG_FILE" | head -n1)
        [ -n "$CLOUDFLARE_URL" ] && break
    done
    [ -z "$CLOUDFLARE_URL" ] && CLOUDFLARE_URL="$LOCAL_URL" || CLOUDFLARE_URL="$CLOUDFLARE_URL/"
    log "🌐 Cloudflare tunnel URL: $CLOUDFLARE_URL"
    termux-open-url "$CLOUDFLARE_URL"

    # Keep server running
    log "⏱️ Server & tunnel running for $TOTAL_MINUTES minutes. Ctrl+C to stop early."
    trap 'log "💤 Manual stop triggered!"; kill $SERVER_PID $TUNNEL_PID 2>/dev/null; rm -f "$LOG_FILE"; exit 0' SIGINT

    while [ $TOTAL_MINUTES -gt 0 ]; do
        printf "\rTime remaining: %2d minutes " $TOTAL_MINUTES
        sleep 60
        TOTAL_MINUTES=$((TOTAL_MINUTES - 1))
    done

    log "💤 Time's up! Stopping local server and tunnel..."
    kill $SERVER_PID 2>/dev/null || true
    kill $TUNNEL_PID 2>/dev/null || true
    rm -f "$LOG_FILE"

    # Cleanup old previews
    log "🧹 Cleaning old previews..."
    find "$COMPRESSED" -type f -name "*.mp4" -mtime +"$RETENTION_DAYS" -exec rm -f {} \;
    log "✅ Fast Preview Finished"
}

# ===== Stop Workflow =====
function stop_workflow() {
    log "🛑 Stopping Hutana Server & Tunnel..."
    pkill -f "http.server $PORT" 2>/dev/null && log "✅ Local server stopped" || log "ℹ️ Server not running"
    pkill -f "cloudflared tunnel" 2>/dev/null && log "✅ Cloudflare tunnel stopped" || log "ℹ️ Tunnel not running"
    log "🧹 Cleanup complete"
}

# ===== Status =====
function status_workflow() {
    SERVER=$(pgrep -f "http.server $PORT" || true)
    TUNNEL=$(pgrep -f "cloudflared tunnel" || true)

    log "🌐 Hutana Server & Tunnel Status"
    [ -n "$SERVER" ] && log "✅ Local server running (PID: $SERVER)" || log "❌ Local server not running"
    [ -n "$TUNNEL" ] && log "✅ Cloudflare tunnel running (PID: $TUNNEL)" || log "❌ Cloudflare tunnel not running"
}

# ===== Main =====
case "$1" in
    start) start_workflow ;;
    stop) stop_workflow ;;
    status) status_workflow ;;
    *) echo "Usage: $0 {start|stop|status}"; exit 1 ;;
esac

