
#!/bin/bash
echo "📂 Setting up Hearthub project structure using existing public folder..."

# Ensure required directories exist inside public
mkdir -p public/images
mkdir -p public/css
mkdir -p public/js

# Move or copy existing files into the correct subfolders if they exist
[ -f heart.jpg ] && mv heart.jpg public/images/heart.jpg
[ -f index.html ] && mv index.html public/index.html
[ -f style.css ] && mv style.css public/css/style.css
[ -f script.js ] && mv script.js public/js/script.js

echo "✅ Hearthub structure is ready (using existing public/ folder)."
