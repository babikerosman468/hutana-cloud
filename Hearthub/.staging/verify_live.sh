
#!/bin/bash
# verify_live.sh - Check live Vercel deployment for public access

if [ -z "$1" ]; then
    echo "Usage: ./verify_live.sh <Vercel URL>"
    exit 1
fi

BASE_URL="$1"
echo "🌐 Verifying live site: $BASE_URL"

# List of pages to check
PAGES=("index.html" "dashboard.html" "contact.html" "index1.html" "index3.html" "vision_mission.html")

# List of key assets to check
ASSETS=("heart.jpg" "css/style.css" "js/script.js")

# Function to check HTTP status
check_url() {
    URL="$BASE_URL/$1"
    STATUS=$(curl -o /dev/null -s -w "%{http_code}" "$URL")
    if [ "$STATUS" -eq 200 ]; then
        echo "✅ $1 accessible (HTTP $STATUS)"
    else
        echo "⚠️ $1 NOT accessible (HTTP $STATUS)"
    fi
}

# Check pages
echo "🔹 Checking HTML pages..."
for page in "${PAGES[@]}"; do
    check_url "$page"
done

# Check assets
echo "🔹 Checking assets..."
for asset in "${ASSETS[@]}"; do
    check_url "$asset"
done

echo "🎯 Live verification complete!"

