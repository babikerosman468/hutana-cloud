#!/data/data/com.termux/files/usr/bin/bash

#############################################
# HUTANA GIT REPAIR + SYNC SCRIPT
#############################################

BASE=~/hutana_project
REPO=$BASE/hutana-cloud

echo "================================="
echo "HUTANA GIT REPAIR START"
echo "================================="

cd $REPO || exit

#############################################
# 1 Check git repository
#############################################

if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
    git add .
    git commit -m "Initial Hutana repository"
else
    echo "Git repository already exists."
fi

#############################################
# 2 Check remote origin
#############################################

REMOTE=$(git remote)

if [ -z "$REMOTE" ]; then
    echo "Adding GitHub remote..."
    git remote add origin https://github.com/babikerosman468/hutana-cloud.git
else
    echo "Remote origin already configured."
fi

#############################################
# 3 Ensure branch main
#############################################

git branch -M main

#############################################
# 4 Pull remote history safely
#############################################

echo "Pulling remote repository..."

git pull origin main --allow-unrelated-histories --no-edit

#############################################
# 5 Push local repository
#############################################

echo "Pushing to GitHub..."

git add .
git commit -m "Hutana update $(date +%Y%m%d_%H%M)" 2>/dev/null

git push -u origin main

echo
echo "================================="
echo "HUTANA GIT SYNC COMPLETE"
echo "================================="

