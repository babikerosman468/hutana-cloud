
#!/bin/bash

echo "===== Cleaning Hearthub Git Repository ====="

HEARTHUB="$HOME/hutana_project/Hearthub"

# Check if .git exists
if [ -d "$HEARTHUB/.git" ]; then
    echo "Found .git in Hearthub. Removing..."
    rm -rf "$HEARTHUB/.git"
    echo "✅ Hearthub Git repository removed."
else
    echo "No .git repository found in Hearthub. Nothing to remove."
fi

echo "===== Hearthub Git Cleanup Complete ====="

