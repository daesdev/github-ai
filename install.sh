#!/bin/bash

# GitHub AI Setup - Single Command Installer
# Usage: curl -sL https://raw.githubusercontent.com/darioesp/github-ai/main/install.sh | bash

set -e

echo "🚀 GitHub AI Setup"

# Default base URL
BASE_URL="${GITHUB_AI_BASE_URL:-https://raw.githubusercontent.com/darioesp/github-ai/main}"

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
    
    # Create directories
    mkdir -p .github/ai
    
    # Install instruction files
    echo "📄 Installing instruction files..."
    cp -f "$temp_dir/commit-message.md" .github/ai/
    cp -f "$temp_dir/pr-description.md" .github/ai/
    echo "  ✅ Installed .github/ai/commit-message.md"
    echo "  ✅ Installed .github/ai/pr-description.md"
    
    # Add VS Code settings
    echo "📝 Configuring VS Code settings..."
    configure_vscode_settings
    
    rm -rf "$temp_dir"
}

install_from_local() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Create directories
    mkdir -p .github/ai
    
    # Install instruction files
    echo "📄 Installing instruction files..."
    cp -f "$script_dir/.github/ai/commit-message.md" .github/ai/
    cp -f "$script_dir/.github/ai/pr-description.md" .github/ai/
    echo "  ✅ Installed .github/ai/commit-message.md"
    echo "  ✅ Installed .github/ai/pr-description.md"
    
    # Add VS Code settings
    echo "📝 Configuring VS Code settings..."
    configure_vscode_settings
}

configure_vscode_settings() {
    # Ensure .vscode directory exists
    mkdir -p .vscode
    
    if [ -f ".vscode/settings.json" ]; then
        # Backup first
        BACKUP_DIR="$HOME/.daes"
        mkdir -p "$BACKUP_DIR"
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        cp -f .vscode/settings.json "$BACKUP_DIR/settings_${TIMESTAMP}.json"
        echo "  ✅ Backed up settings.json"
        
        # Use python to safely add keys
        if command -v python3 &> /dev/null; then
            python3 << 'PYEOF'
import json
import os

settings_file = '.vscode/settings.json'
backup_file = settings_file + '.bak'

# Keys to add
commit_key = "github.copilot.chat.commitMessageGeneration.instructions"
commit_value = [{"file": ".github/ai/commit-message.md"}]

pr_key = "github.copilot.chat.pullRequestDescriptionGeneration.instructions"
pr_value = [{"file": ".github/ai/pr-description.md"}]

# Create backup before modifying
if os.path.exists(settings_file):
    with open(settings_file, 'r') as f:
        original_content = f.read()
    with open(backup_file, 'w') as f:
        f.write(original_content)

# Load existing
try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)
except json.JSONDecodeError as e:
    print(f"  ⚠️  Invalid JSON in settings.json, using backup")
    with open(backup_file, 'r') as f:
        settings = json.load(f)
except Exception as e:
    print(f"  ⚠️  Error reading settings.json: {e}")
    settings = {}

# Add keys only if they don't exist
if commit_key not in settings:
    settings[commit_key] = commit_value
    print(f"  ✅ Added: {commit_key}")
else:
    print(f"  ⏭️  Skipped (exists): {commit_key}")

if pr_key not in settings:
    settings[pr_key] = pr_value
    print(f"  ✅ Added: {pr_key}")
else:
    print(f"  ⏭️  Skipped (exists): {pr_key}")

# Write back
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print("✅ VS Code settings configured")
PYEOF
        else
            echo "  ⚠️  Python not found, skipping settings"
        fi
    else
        # No existing file, create new one using Python
        if command -v python3 &> /dev/null; then
            python3 << 'PYEOF'
import json

settings_file = '.vscode/settings.json'

settings = {
    "github.copilot.chat.commitMessageGeneration.instructions": [
        {"file": ".github/ai/commit-message.md"}
    ],
    "github.copilot.chat.pullRequestDescriptionGeneration.instructions": [
        {"file": ".github/ai/pr-description.md"}
    ]
}

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print("✅ Created settings.json")
PYEOF
        else
            echo "  ⚠️  Python not found, skipping settings"
        fi
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
echo "  - .vscode/settings.json (with AI instructions)"
echo ""
echo "Commit messages will now follow Conventional Commits format!"
echo ""
echo "To update in the future, run:"
echo "  curl -sL $BASE_URL/install.sh | bash"