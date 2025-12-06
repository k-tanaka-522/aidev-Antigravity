@echo off
setlocal

echo [Antigravity] Initializing new project...

rem 1. Remove git history to start fresh
if exist ".git" (
    echo [Antigravity] Removing existing git history...
    rmdir /s /q .git
)

rem 2. Initialize new git repository
echo [Antigravity] Initializing new git repository...
git init

rem 3. Remove aidev-antigravity specific documentation (optional)
rem echo [Antigravity] Cleaning up documentation...
rem del README.md
rem del install.ps1
rem del install.sh

rem 4. Create a fresh README for the new project
echo # My New Project > README.md
echo This project is managed by Antigravity Agent Team. >> README.md

echo [Antigravity] Initialization complete!
echo [Antigravity] You can now start using the agent team.

endlocal
