
#!/bin/bash
# update1.sh - Update and deploy site with dashboard search

echo ">>> Renaming copy.html to dashboard.html..."
mv -f copy.html dashboard.html

echo ">>> Patching dashboard.html with multiple search filter..."
cat > dashboard.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Dashboard</title>
  <link rel="stylesheet" href="style.css">
  <script src="script.js" defer></script>
</head>
<body>
  <div class="sidebar">
    <a href="index.html">Home</a>
    <a href="dashboard.html">Dashboard</a>
    <a href="vision_mission.txt">Vision & Mission</a>
  </div>

  <div class="content">
    <h1>Dashboard</h1>
    <input type="text" id="searchBox" placeholder="Search by title, category, or description...">

    <div id="cardContainer">
      <div class="card" data-title="Heart Science" data-category="Biotech" data-description="Exploring heart coherence and consciousness.">
        <h3>Heart Science</h3>
        <p>Exploring heart coherence and consciousness.</p>
      </div>

      <div class="card" data-title="Genomics" data-category="Bioinformatics" data-description="Genome sequencing and analysis for health.">
        <h3>Genomics</h3>
        <p>Genome sequencing and analysis for health.</p>
      </div>

      <div class="card" data-title="AI Platform" data-category="Informatics" data-description="Artificial intelligence tools for simulations.">
        <h3>AI Platform</h3>
        <p>Artificial intelligence tools for simulations.</p>
      </div>
    </div>
  </div>

  <script>
    const searchBox = document.getElementById("searchBox");
    const cards = document.querySelectorAll(".card");

    searchBox.addEventListener("input", () => {
      const query = searchBox.value.toLowerCase();
      cards.forEach(card => {
        const title = card.dataset.title.toLowerCase();
        const category = card.dataset.category.toLowerCase();
        const description = card.dataset.description.toLowerCase();

        if (title.includes(query) || category.includes(query) || description.includes(query)) {
          card.style.display = "block";
        } else {
          card.style.display = "none";
        }
      });
    });
  </script>
</body>
</html>
EOF

echo ">>> Deploying to git..."
git add .
git commit -m "Update dashboard with combined multiple search"
git push origin main

echo ">>> Deployment complete!"

