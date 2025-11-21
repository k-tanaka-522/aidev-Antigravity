#!/bin/bash
# scripts/init-new-project.sh
# 新規プロジェクトとして初期化するためのスクリプト

echo "[Antigravity] Initializing new project..."

# 1. Remove git history to start fresh
if [ -d ".git" ]; then
    echo "[Antigravity] Removing existing git history..."
    rm -rf .git
fi

# 2. Initialize new git repository
echo "[Antigravity] Initializing new git repository..."
git init

# 3. Remove aidev-antigravity specific documentation (optional)
# echo "[Antigravity] Cleaning up documentation..."
# rm README.md
# rm install.ps1
# rm install.sh

# 4. Create a fresh README for the new project
echo "# My New Project" > README.md
echo "This project is managed by Antigravity Agent Team." >> README.md

echo "[Antigravity] Initialization complete!"
echo "[Antigravity] You can now start using the agent team."
echo "[Antigravity] Try running: /init"
