#!/bin/bash

# GitHub AI Setup - Single Command Installer
# Usage: curl -sL https://raw.githubusercontent.com/daesdev/github-ai/main/install.sh | bash

set -e

echo "🚀 GitHub AI Setup"

# Default base URL - change this to your repo
BASE_URL="${GITHUB_AI_BASE_URL:-https://raw.githubusercontent.com/daesdev/github-ai/main}"

# Check if we have stdin (curl | bash) or running locally
is_pipe() {
    [ -t 0 ] && return 1 || return 0
}

install_from_github() {
    local temp_dir=$(mktemp -d)
    
    echo "📥 Downloading files from GitHub..."
    
    # Download commit-message.md
    echo "  Downloading commit-message.md..."
    local commit_file=$(curl -sL "$BASE_URL/.github/ai/commit-message.md")
    if echo "$commit_file" | grep -q "404"; then
        echo "❌ Error: Could not find commit-message.md"
        rm -rf "$temp_dir"
        exit 1
    fi
    echo "$commit_file" > "$temp_dir/commit-message.md"
    
    # Download pr-description.md
    echo "  Downloading pr-description.md..."
    local pr_file=$(curl -sL "$BASE_URL/.github/ai/pr-description.md")
    if echo "$pr_file" | grep -q "404"; then
        echo "❌ Error: Could not find pr-description.md"
        rm -rf "$temp_dir"
        exit 1
    fi
    echo "$pr_file" > "$temp_dir/pr-description.md"
    
    # Download settings.json
    echo "  Downloading settings.json..."
    local settings_file=$(curl -sL "$BASE_URL/.vscode/settings.json")
    if echo "$settings_file" | grep -q "404"; then
        echo "❌ Error: Could not find settings.json"
        rm -rf "$temp_dir"
        exit 1
    fi
    echo "$settings_file" > "$temp_dir/settings.json"
    
    # Create directories
    mkdir -p .github/ai
    mkdir -p .vscode
    
    # Handle commit-message.md - always copy (creates or updates)
    echo "📄 Installing commit-message.md..."
    cp -f "$temp_dir/commit-message.md" .github/ai/
    echo "  ✅ commit-message.md installed"
    
    # Handle pr-description.md - always copy (creates or updates)
    echo "📄 Installing pr-description.md..."
    cp -f "$temp_dir/pr-description.md" .github/ai/
    echo "  ✅ pr-description.md installed"
    
    # Handle settings.json
    echo "📝 Setting up VS Code settings..."
    if [ -f ".vscode/settings.json" ]; then
        # Backup before merging
        BACKUP_DIR="$HOME/.daes"
        mkdir -p "$BACKUP_DIR"
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        cp -f .vscode/settings.json "$BACKUP_DIR/settings_${TIMESTAMP}.json"
        
        echo "  Merging with existing settings.json..."
        
        if command -v python3 &> /dev/null; then
            python3 - "$temp_dir" << 'PYEOF'
import sys
import json
import os

temp_dir = sys.argv[1]
settings_file = '.vscode/settings.json'

# Load new settings (the ones from GitHub)
new_settings = json.load(open(os.path.join(temp_dir, 'settings.json')))

# Load existing settings
with open(settings_file, 'r') as f:
    existing = json.load(f)

# Only add keys that don't exist in existing
for key, value in new_settings.items():
    if key not in existing:
        existing[key] = value
        print(f"  Added: {key}")
    else:
        print(f"  Skipped (exists): {key}")

# Write merged result
with open(settings_file, 'w') as f:
    json.dump(existing, f, indent=2)
print("✅ settings.json merged")
PYEOF
        else
            echo "  ⚠️  Python not found, skipping merge"
        fi
    else
        # No existing file, just copy
        cp -f "$temp_dir/settings.json" .vscode/settings.json
        echo "  ✅ Created settings.json"
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
}

install_from_local() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Create directories
    mkdir -p .github/ai
    mkdir -p .vscode
    
    # Handle commit-message.md - always copy
    echo "📄 Installing commit-message.md..."
    cp -f "$script_dir/.github/ai/commit-message.md" .github/ai/
    echo "  ✅ commit-message.md installed"
    
    # Handle pr-description.md - always copy
    echo "📄 Installing pr-description.md..."
    cp -f "$script_dir/.github/ai/pr-description.md" .github/ai/
    echo "  ✅ pr-description.md installed"
    
    # Handle settings.json
    echo "📝 Setting up VS Code settings..."
    if [ -f ".vscode/settings.json" ]; then
        # Backup before merging
        BACKUP_DIR="$HOME/.daes"
        mkdir -p "$BACKUP_DIR"
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        cp -f .vscode/settings.json "$BACKUP_DIR/settings_${TIMESTAMP}.json"
        
        echo "  Merging with existing settings.json..."
        
        if command -v python3 &> /dev/null; then
            python3 - "$script_dir" << 'PYEOF'
import sys
import json
import os

script_dir = sys.argv[1]
settings_file = '.vscode/settings.json'

# Load new settings
new_settings = json.load(open(os.path.join(script_dir, '.vscode/settings.json')))

# Load existing settings
with open(settings_file, 'r') as f:
    existing = json.load(f)

# Only add keys that don't exist in existing
for key, value in new_settings.items():
    if key not in existing:
        existing[key] = value
        print(f"  Added: {key}")
    else:
        print(f"  Skipped (exists): {key}")

# Write merged result
with open(settings_file, 'w') as f:
    json.dump(existing, f, indent=2)
print("✅ settings.json merged")
PYEOF
        else
            echo "  ⚠️  Python not found, skipping merge"
        fi
    else
        cp -f "$script_dir/.vscode/settings.json" .vscode/settings.json
        echo "  ✅ Created settings.json"
    fi
}

# Determine installation method
if is_pipe; then
    install_from_github
else
    install_from_local
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "Your project now has:"
echo "  - .github/ai/commit-message.md"
echo "  - .github/ai/pr-description.md"
echo "  - .vscode/settings.json"
echo ""
echo "Commit messages will now follow Conventional Commits format!"
echo ""
echo "To update in the future, run:"
echo "  curl -sL $BASE_URL/install.sh | bash"