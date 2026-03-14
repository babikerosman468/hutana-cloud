
#!/bin/bash
# vercel_list.sh - List all Vercel projects with ID and name

echo "🔎 Fetching Vercel projects..."
PROJECTS=$(vercel projects ls --confirm --json 2>/dev/null)

if [ -z "$PROJECTS" ]; then
  echo "✅ No projects found."
  exit 0
fi

# Show the JSON structure clearly
echo "$PROJECTS" | jq '.projects[] | {id: .id, name: .name}'
