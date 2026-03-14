
#!/bin/bash
# vercel_clean.sh - Safely delete all Vercel projects

echo "🔎 Fetching list of your Vercel projects..."

# Get JSON list
projects_json=$(vercel projects list --json 2>/dev/null)

# Check if command succeeded
if [ $? -ne 0 ] || [ -z "$projects_json" ]; then
    echo "❌ Failed to fetch projects. Make sure you are logged in with 'vercel login'."
    exit 1
fi

# Count projects
project_count=$(echo "$projects_json" | jq 'length' 2>/dev/null)

if [ "$project_count" -eq 0 ]; then
    echo "✅ No projects found. Nothing to delete."
    exit 0
fi

echo "⚠️  Found $project_count projects. Proceeding with deletion..."

# Loop through safely
echo "$projects_json" | jq -c '.[]' | while read -r proj; do
    id=$(echo "$proj" | jq -r '.id // empty')
    name=$(echo "$proj" | jq -r '.name // empty')

    if [ -n "$id" ] && [ -n "$name" ]; then
        echo "🗑️  Deleting project: $name ($id)..."
        vercel projects rm "$id" --yes >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "✅ Deleted $name"
        else
            echo "❌ Failed to delete $name"
        fi
    fi
done
