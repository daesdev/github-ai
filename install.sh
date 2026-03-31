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
        echo "❌ Error: Could not find commit-message.md at $BASE_URL/.github/ai/commit-message.md"
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
    
    # Copy instruction files
    echo "📄 Installing instruction files..."
    cp -f "$temp_dir/commit-message.md" .github/ai/
    cp -f "$temp_dir/pr-description.md" .github/ai/
    
    # Handle settings.json
    echo "📝 Setting up VS Code settings..."
    if [ -f ".vscode/settings.json" ]; then
        echo "  Merging with existing settings.json..."
        
        if grep -q "github.copilot.chat.commitMessageGeneration.instructions" .vscode/settings.json 2>/dev/null; then
            echo "⚠️  AI settings already present, skipping..."
        else
            if command -v python3 &> /dev/null; then
                python3 << 'PYEOF'
import json

settings_file = '.vscode/settings.json'
new_settings = json.load(open('$temp_dir/settings.json'))

try:
    existing = json.load(open(settings_file))
except:
    existing = {}

for key, value in new_settings.items():
    if key not in existing:
        existing[key] = value
    elif isinstance(value, list) and isinstance(existing[key], list):
        existing[key] = existing[key] + value
    elif isinstance(value, dict) and isinstance(existing[key], dict):
        existing[key] = {**existing[key], **value}
    else:
        existing[key] = value

with open(settings_file, 'w') as f:
    json.dump(existing, f, indent=2)
print("✅ Updated settings.json")
PYEOF
            else
                echo "⚠️  Python not found, creating new settings.json (backup existing)"
                cp -f .vscode/settings.json .vscode/settings.json.bak
                cp -f "$temp_dir/settings.json" .vscode/settings.json
                echo "✅ Created settings.json (backed up old to .bak)"
            fi
        fi
    else
        cp -f "$temp_dir/settings.json" .vscode/settings.json
        echo "✅ Created settings.json"
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
}

install_from_local() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Create directories
    mkdir -p .github/ai
    mkdir -p .vscode
    
    # Copy files
    echo "📄 Installing from local..."
    cp -f "$script_dir/.github/ai/commit-message.md" .github/ai/
    cp -f "$script_dir/.github/ai/pr-description.md" .github/ai/
    
    # Handle settings.json
    if [ -f ".vscode/settings.json" ]; then
        echo "📝 Merging with existing settings.json..."
        
        if grep -q "github.copilot.chat.commitMessageGeneration.instructions" .vscode/settings.json 2>/dev/null; then
            echo "⚠️  AI settings already present, skipping..."
        else
            if command -v python3 &> /dev/null; then
                python3 << 'PYEOF'
import json

settings_file = '.vscode/settings.json'
new_settings = json.load(open('$script_dir/.vscode/settings.json'))

try:
    existing = json.load(open(settings_file))
except:
    existing = {}

for key, value in new_settings.items():
    if key not in existing:
        existing[key] = value
    elif isinstance(value, list) and isinstance(existing[key], list):
        existing[key] = existing[key] + value
    elif isinstance(value, dict) and isinstance(existing[key], dict):
        existing[key] = {**existing[key], **value}
    else:
        existing[key] = value

with open(settings_file, 'w') as f:
    json.dump(existing, f, indent=2)
print("✅ Updated settings.json")
PYEOF
            else
                echo "⚠️  Python not found, skipping settings merge"
            fi
        fi
    else
        cp -f "$script_dir/.vscode/settings.json" .vscode/settings.json
        echo "✅ Created settings.json"
    fi
}

# Determine installation method
if is_pipe; then
    # Running via curl | bash
    install_from_github
else
    # Running locally
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