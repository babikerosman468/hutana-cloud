
#!/data/data/com.termux/files/usr/bin/bash
# ======================================================
# Hearthub All-in-One Manager
#  - Local Navigation Injection
#  - Local Test Server
#  - Vercel Deployment (Git-free)
# ======================================================

HEARTHUB_DIR="$(pwd)"
NAV_FILE="$HEARTHUB_DIR/nav.html"          # Your unified navigation
STAGING_DIR="$HEARTHUB_DIR/.staging"      # Temporary folder for Vercel deploy
BROWSER="http://127.0.0.1:3000"
SERVER_PID_FILE="$HEARTHUB_DIR/server.pid"

# -------------------------------
# Inject navigation into HTML
# -------------------------------
inject_nav() {
    echo "🔧 Injecting unified navigation into HTML pages..."
    mkdir -p "$HEARTHUB_DIR/.bak"
    for html in "$HEARTHUB_DIR"/*.html; do
        [ -f "$html" ] || continue
        cp "$html" "$HEARTHUB_DIR/.bak/"    # backup
        if [ -f "$NAV_FILE" ]; then
            perl -i -pe '
                BEGIN {
                    open(NAV,"'$NAV_FILE'") or die "Cannot open nav file";
                    @nav=<NAV>; close NAV;
                    $nav_content = join("",@nav);
                }
                if(/<body>/i && !$injected++){ $_ .= $nav_content }
            ' "$html"
        fi
    done
    echo "✅ HTML pages processed. Backups in .bak/"
}

# -------------------------------
# Start local server
# -------------------------------
start_server() {
    echo "🌐 Starting local static server at $BROWSER ..."
    if command -v python3 >/dev/null 2>&1; then
        python3 -m http.server 3000 &
        SERVER_PID=$!
        echo "$SERVER_PID" > "$SERVER_PID_FILE"
        sleep 1
        echo "🔗 Server started with PID $SERVER_PID"
        am start -a android.intent.action.VIEW -d "$BROWSER" >/dev/null 2>&1
    else
        echo "❌ Python3 not found. Install it to serve Hearthub locally."
    fi
}

# -------------------------------
# Stop local server
# -------------------------------
stop_server() {
    if [ -f "$SERVER_PID_FILE" ]; then
        PID=$(cat "$SERVER_PID_FILE")
        if ps -p "$PID" >/dev/null 2>&1; then
            kill "$PID"
            echo "🛑 Server stopped (PID $PID)"
        else
            echo "⚠️ No running server found"
        fi
        rm -f "$SERVER_PID_FILE"
    else
        echo "⚠️ Server PID file not found"
    fi
}

# -------------------------------
# Vercel deployment (Git-free)
# -------------------------------
deploy_vercel() {
    echo "🌐 Deploying Hearthub to Vercel (Git-free)..."
    mkdir -p "$STAGING_DIR"
    rsync -av --exclude='.staging' "$HEARTHUB_DIR/" "$STAGING_DIR/"
    if command -v vercel >/dev/null 2>&1; then
        vercel --prod --confirm "$STAGING_DIR"
        if [ $? -eq 0 ]; then
            echo "✅ Deployed to Vercel successfully!"
        else
            echo "❌ Deployment failed. Check Vercel logs."
        fi
    else
        echo "❌ Vercel CLI not installed. Install with: npm i -g vercel"
    fi
}

# -------------------------------
# Full deploy (local + vercel)
# -------------------------------
full_deploy() {
    inject_nav
    start_server
    deploy_vercel
    echo "🎉 Full Hearthub deployment complete!"
}

# -------------------------------
# Main
# -------------------------------
case "$1" in
    inject) inject_nav ;;
    start) start_server ;;
    stop) stop_server ;;
    deploy) full_deploy ;;
    vercel) deploy_vercel ;;
    *) 
        echo "Usage: $0 {inject|start|stop|deploy|vercel}"
        ;;
esac

