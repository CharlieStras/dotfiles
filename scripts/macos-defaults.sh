#!/usr/bin/env bash
# scripts/macos-defaults.sh - macOS system preferences
# Uncomment or tweak entries as needed

echo "→ Applying macOS system preferences..."

# Dock
defaults write com.apple.dock autohide -bool true                # Auto-hide the Dock
defaults write com.apple.dock show-recents -bool false           # Hide recent apps

# Restart Dock to apply changes
killall Dock

echo "  macOS preferences applied"
