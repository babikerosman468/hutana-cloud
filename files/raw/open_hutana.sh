
#!/bin/bash
# Helper script to open Hutana Fast Preview

# Replace this with your current Cloudflare tunnel URL
HUTANA_URL="https://valley-outcome-special-.trycloudflare.com/"

# Open in default browser
xdg-open "$HUTANA_URL" 2>/dev/null || open "$HUTANA_URL"

echo "🌐 Opening Hutana Fast Preview gallery..."
