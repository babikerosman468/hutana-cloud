
#!/bin/bash
# verify_public.sh - Check that all HTML, CSS, JS, and images are correctly referenced and exist in root

ROOT_DIR="$(pwd)"
echo "🔍 Verifying public deployment from $ROOT_DIR"

# Step 1: Find all HTML files
HTML_FILES=$(find "$ROOT_DIR" -maxdepth 1 -name "*.html")

# Step 2: Check each HTML file for asset paths
echo "✅ Checking HTML files and linked assets..."
for html in $HTML_FILES; do
    echo "• Checking $html"
    # Extract src and href paths from HTML
    grep -Eo '(src|href)="[^"]+"' "$html" | while read -r line; do
        path=$(echo "$line" | cut -d'"' -f2)
        # Skip absolute URLs (http, https, mailto)
        if [[ "$path" =~ ^(http|https|mailto) ]]; then
            continue
        fi
        # Resolve relative path
        target="$ROOT_DIR/$path"
        if [ -f "$target" ] || [ -d "$target" ]; then
            echo "  ✅ Found: $path"
        else
            echo "  ⚠️ Missing: $path"
        fi
    done
done

# Step 3: Optional: Test Vercel URL if provided
if [ ! -z "$1" ]; then
    URL="$1"
    echo "🌐 Testing public URLs at $URL"
    for html in $HTML_FILES; do
        file=$(basename "$html")
        status=$(curl -o /dev/null -s -w "%{http_code}\n" "$URL/$file")
        if [ "$status" -eq 200 ]; then
            echo "  ✅ $file is accessible (HTTP $status)"
        else
            echo "  ⚠️ $file NOT accessible (HTTP $status)"
        fi
    done
fi

echo "🎯 Verification complete."

