
#!/data/data/com.termux/files/usr/bin/bash
# ======================================================
# BabsApp All-in-One Installer & Manager (Termux)
# Installs MariaDB + Node.js if missing, manages services,
# opens browser, handles logs, folders, stale processes
# ======================================================

APP_FILE="server6.js"
PORT=3010
NODE_PID_FILE="node.pid"
MYSQL_PID_FILE="mariadb.pid"
BASE_DIR="$HOME/hutana_project/babsapp"
MYSQL_DATA_DIR="$BASE_DIR/mysql_data"
LOG_DIR="$BASE_DIR/logs"
MYSQL_LOG="$LOG_DIR/mariadb.log"
NODE_LOG="$LOG_DIR/node.log"

# --------------------------
# Ensure essential folders exist
# --------------------------
mkdir -p "$MYSQL_DATA_DIR"
mkdir -p "$LOG_DIR"

# --------------------------
# Helpers
# --------------------------
cleanup_stale_mariadb() {
    echo "🧹 Checking for stale MariaDB processes..."
    for pid in $(pgrep -f "mysqld"); do
        echo "⚠️ Killing stale MariaDB process with PID $pid"
        kill -9 "$pid"
    done
}

get_mariadb_pid() {
    if [ -f "$MYSQL_DATA_DIR/localhost.pid" ]; then
        cat "$MYSQL_DATA_DIR/localhost.pid"
    else
        pgrep -f "mysqld" | head -n 1
    fi
}

is_running() {
    local pid=$1
    [ -n "$pid" ] && ps -p "$pid" > /dev/null 2>&1
}

install_node() {
    if ! command -v node >/dev/null 2>&1; then
        echo "📦 Node.js not found, installing..."
        pkg install -y nodejs
    fi
}

install_mariadb() {
    if ! command -v mysqld >/dev/null 2>&1; then
        echo "📦 MariaDB not found, installing..."
        pkg install -y mariadb
        echo "✅ MariaDB installed"
        mysql_install_db --datadir="$MYSQL_DATA_DIR" --user="$(whoami)" >/dev/null 2>&1
    fi
}

# --------------------------
# Start Services
# --------------------------
start_db() {
    echo "🔵 Starting MariaDB..."
    cleanup_stale_mariadb
    if pgrep -f "mysqld" >/dev/null; then
        echo "✅ MariaDB already running."
        return
    fi
    mysqld_safe --datadir="$MYSQL_DATA_DIR" > "$MYSQL_LOG" 2>&1 &
    sleep 3
    MARIADB_REAL_PID=$(get_mariadb_pid)
    if [ -n "$MARIADB_REAL_PID" ]; then
        echo "$MARIADB_REAL_PID" > "$MYSQL_PID_FILE"
        echo "✅ MariaDB started with PID $MARIADB_REAL_PID"
    else
        echo "❌ Failed to start MariaDB. Check logs at $MYSQL_LOG"
    fi
}

start_node() {
    echo "🟢 Starting Node.js server on port $PORT..."
    if [ ! -f "$APP_FILE" ]; then
        echo "❌ Node.js entry file $APP_FILE not found!"
        return 1
    fi
    node "$APP_FILE" > "$NODE_LOG" 2>&1 &
    NODE_PID=$!
    sleep 1
    if is_running "$NODE_PID"; then
        echo "$NODE_PID" > "$NODE_PID_FILE"
        echo "🔗 Node.js server started with PID $NODE_PID"
        am start -a android.intent.action.VIEW -d "http://127.0.0.1:$PORT" > /dev/null 2>&1
        echo "🌐 Browser launched at http://127.0.0.1:$PORT"
    else
        echo "❌ Failed to start Node.js server."
    fi
}

start_all() {
    install_node
    install_mariadb
    start_db
    start_node
}

# --------------------------
# Stop Services
# --------------------------
stop_db() {
    if [ -f "$MYSQL_PID_FILE" ]; then
        PID=$(cat "$MYSQL_PID_FILE")
        if is_running "$PID"; then
            kill "$PID" 2>/dev/null
            echo "✅ MariaDB (PID $PID) stopped"
        fi
        rm -f "$MYSQL_PID_FILE"
    fi
    cleanup_stale_mariadb
}

stop_node() {
    if [ -f "$NODE_PID_FILE" ]; then
        PID=$(cat "$NODE_PID_FILE")
        if is_running "$PID"; then
            kill "$PID" 2>/dev/null
            echo "✅ Node.js server (PID $PID) stopped"
        fi
        rm -f "$NODE_PID_FILE"
    fi
}

stop_all() {
    stop_node
    stop_db
}

# --------------------------
# Status
# --------------------------
status() {
    echo "📊 MariaDB status:"
    if [ -f "$MYSQL_PID_FILE" ]; then
        PID=$(cat "$MYSQL_PID_FILE")
        if is_running "$PID"; then
            echo "✅ Running (PID $PID)"
        else
            echo "❌ Not running (stale PID)"
        fi
    else
        echo "❌ Not running"
    fi

    echo "📊 Node.js server status:"
    if [ -f "$NODE_PID_FILE" ]; then
        PID=$(cat "$NODE_PID_FILE")
        if is_running "$PID"; then
            echo "✅ Running (PID $PID)"
        else
            echo "❌ Not running (stale PID)"
        fi
    else
        echo "❌ Not running"
    fi
}

# --------------------------
# Main
# --------------------------
case "$1" in
    start_db) install_mariadb; start_db ;;
    start_node) install_node; start_node ;;
    start) start_all ;;
    stop_db) stop_db ;;
    stop_node) stop_node ;;
    stop) stop_all ;;
    status) status ;;
    fullstop) stop_all ;;
    *) 
        echo "Usage: $0 {start|stop|status|start_db|start_node|stop_db|stop_node|fullstop}"
        ;;
esac

