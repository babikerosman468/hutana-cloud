#!/bin/bash
# Script to add multi-page HTML files with navbar + footer

# Dashboard page
cat > dashboard.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hearthub - Dashboard</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <nav class="navbar">
    <div class="logo">Hearthub</div>
    <ul class="nav-links">
      <li><a href="index.html">Home</a></li>
      <li><a href="dashboard.html">Dashboard</a></li>
      <li><a href="vision_mission.html">Vision & Mission</a></li>
      <li><a href="contact.html">Contact</a></li>
    </ul>
  </nav>

  <section>
    <h1>Dashboard</h1>
    <p>Here you will find the main tools, analytics, and features of Hearthub.</p>
  </section>

  <footer class="footer">
    <p>&copy; 2025 Hearthub. All rights reserved.</p>
    <ul class="footer-links">
      <li><a href="index.html">Home</a></li>
      <li><a href="dashboard.html">Dashboard</a></li>
      <li><a href="vision_mission.html">Vision & Mission</a></li>
      <li><a href="contact.html">Contact</a></li>
    </ul>
  </footer>
</body>
</html>
EOF

# Vision & Mission page
cat > vision_mission.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hearthub - Vision & Mission</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <nav class="navbar">
    <div class="logo">Hearthub</div>
    <ul class="nav-links">
      <li><a href="index.html">Home</a></li>
      <li><a href="dashboard.html">Dashboard</a></li>
      <li><a href="vision_mission.html">Vision & Mission</a></li>
      <li><a href="contact.html">Contact</a></li>
    </ul>
  </nav>

  <section>
    <h1>Vision & Mission</h1>
    <p>Our mission is to connect coherent hearts, foster collaboration, and build resilience.</p>
  </section>

  <footer class="footer">
    <p>&copy; 2025 Hearthub. All rights reserved.</p>
    <ul class="footer-links">
      <li><a href="index.html">Home</a></li>
      <li><a href="dashboard.html">Dashboard</a></li>
      <li><a href="vision_mission.html">Vision & Mission</a></li>
      <li><a href="contact.html">Contact</a></li>
    </ul>
  </footer>
</body>
</html>
EOF

# Contact page
cat > contact.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hearthub - Contact</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <nav class="navbar">
    <div class="logo">Hearthub</div>
    <ul class="nav-links">
      <li><a href="index.html">Home</a></li>
      <li><a href="dashboard.html">Dashboard</a></li>
      <li><a href="vision_mission.html">Vision & Mission</a></li>
      <li><a href="contact.html">Contact</a></li>
    </ul>
  </nav>

  <section>
    <h1>Contact</h1>
    <p>Email: info@hearthub.org</p>
    <p>We’d love to hear from you! Reach out with questions, feedback, or collaboration ideas.</p>
  </section>

  <footer class="footer">
    <p>&copy; 2025 Hearthub. All rights reserved.</p>
    <ul class="footer-links">
      <li><a href="index.html">Home</a></li>
      <li><a href="dashboard.html">Dashboard</a></li>
      <li><a href="vision_mission.html">Vision & Mission</a></li>
      <li><a href="contact.html">Contact</a></li>
    </ul>
  </footer>
</body>
</html>
EOF

echo "✅ Pages added: dashboard.html, vision_mission.html, contact.html"

