
#!/bin/bash
# full_deploy.sh - GitHub + Vercel unified deploy script

COMMIT_MSG="Auto-update $(date '+%Y-%m-%d %H:%M:%S')"

echo "🚀 Starting full deployment..."

# Step 1: Git operations
echo "📤 Staging all changes..."
git add -A
git commit -m "$COMMIT_MSG"
git push origin main
echo "✅ Pushed to GitHub."

# Step 2: Vercel deployment
echo "🌐 Deploying to Vercel production..."
DEPLOY_OUTPUT=$(vercel --prod --confirm --force 2>&1)

# Extract deployed URL
DEPLOY_URL=$(echo "$DEPLOY_OUTPUT" | grep -o 'https://[a-zA-Z0-9.-]*vercel.app' | head -n1)

if [ -n "$DEPLOY_URL" ]; then
    echo "✅ Deployed: $DEPLOY_URL"
    # Open in Termux browser if available
    termux-open "$DEPLOY_URL" 2>/dev/null || echo "🌟 Open your browser and visit: $DEPLOY_URL"
else
    echo "⚠️ Deployment finished but URL not found."
fi

echo "🎉 Full deployment finished!"
