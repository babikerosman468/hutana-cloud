
#!/bin/bash
# Hearthub deployment script (Vercel only, no Git)

echo "🚀 Deploying Hearthub..."

echo "📁 Working directory:"
pwd

echo "🌐 Deploying to Vercel..."
DEPLOY_OUTPUT=$(vercel --prod --confirm --force 2>&1)

DEPLOY_URL=$(echo "$DEPLOY_OUTPUT" | grep -o 'https://[a-zA-Z0-9.-]*vercel.app' | head -n1)

if [ -n "$DEPLOY_URL" ]; then
    echo "✅ Hearthub deployed:"
    echo "$DEPLOY_URL"
    termux-open "$DEPLOY_URL" 2>/dev/null
else
    echo "⚠️ Deployment finished but URL not detected."
fi

echo "🎉 Hearthub deployment finished."







