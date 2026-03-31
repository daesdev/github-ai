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
        echo "  Backing up existing settings.json..."
        
        BACKUP_DIR="$HOME/.daes"
        mkdir -p "$BACKUP_DIR"
        
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        BACKUP_FILE="$BACKUP_DIR/settings_${TIMESTAMP}.json"
        
        cp -f .vscode/settings.json "$BACKUP_FILE"
        cp -f .vscode/settings.json "$BACKUP_DIR/settings_latest.json"
        echo "  ✅ Backup saved to: $BACKUP_FILE"
        
        echo "  Adding AI settings to existing configuration..."
        
        if command -v python3 &> /dev/null; then
            python3 - "$temp_dir" << 'PYEOF'
import sys
import json
import os

temp_dir = sys.argv[1]
settings_file = '.vscode/settings.json'

try:
    new_settings = json.load(open(os.path.join(temp_dir, 'settings.json')))
except Exception as e:
    print(f"❌ Error: Cannot read new settings.json: {e}")
    sys.exit(1)

try:
    with open(settings_file, 'r') as f:
        existing = json.load(f)
except json.JSONDecodeError as e:
    print(f"⚠️  Existing settings.json is malformed: {e}")
    backup_file = os.path.join(os.path.expanduser('~'), '.daes', 'settings_latest.json')
    if os.path.exists(backup_file):
        print("   Trying to restore from backup...")
        try:
            with open(backup_file, 'r') as f:
                existing = json.load(f)
            print("✅ Restored from backup")
        except:
            print("⚠️  Backup also malformed, creating fresh settings...")
            existing = {}
    else:
        print("   Creating fresh settings file...")
        existing = {}
except Exception as e:
    print(f"⚠️  Cannot read existing settings.json: {e}")
    existing = {}

for key, value in new_settings.items():
    if key not in existing:
        existing[key] = value
    elif isinstance(value, list) and isinstance(existing[key], list):
        for item in value:
            if item not in existing[key]:
                existing[key].append(item)
    elif isinstance(value, dict) and isinstance(existing[key], dict):
        for subkey, subvalue in value.items():
            if subkey not in existing[key]:
                existing[key][subkey] = subvalue

with open(settings_file, 'w') as f:
    json.dump(existing, f, indent=2)
print("✅ settings.json updated (existing keys preserved)")
PYEOF
        else
            echo "⚠️  Python not found, skipping settings update"
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
        echo "  Backing up existing settings.json..."
        
        BACKUP_DIR="$HOME/.daes"
        mkdir -p "$BACKUP_DIR"
        
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        BACKUP_FILE="$BACKUP_DIR/settings_${TIMESTAMP}.json"
        
        cp -f .vscode/settings.json "$BACKUP_FILE"
        cp -f .vscode/settings.json "$BACKUP_DIR/settings_latest.json"
        echo "  ✅ Backup saved to: $BACKUP_FILE"
        
        echo "  Adding AI settings to existing configuration..."
        
        if command -v python3 &> /dev/null; then
            python3 - "$script_dir" << 'PYEOF'
import sys
import json
import os

script_dir = sys.argv[1]
settings_file = '.vscode/settings.json'

try:
    new_settings = json.load(open(os.path.join(script_dir, '.vscode/settings.json')))
except Exception as e:
    print(f"❌ Error: Cannot read new settings.json: {e}")
    sys.exit(1)

try:
    with open(settings_file, 'r') as f:
        existing = json.load(f)
except json.JSONDecodeError as e:
    print(f"⚠️  Existing settings.json is malformed: {e}")
    backup_file = os.path.join(os.path.expanduser('~'), '.daes', 'settings_latest.json')
    if os.path.exists(backup_file):
        print("   Trying to restore from backup...")
        try:
            with open(backup_file, 'r') as f:
                existing = json.load(f)
            print("✅ Restored from backup")
        except:
            print("⚠️  Backup also malformed, creating fresh settings...")
            existing = {}
    else:
        print("   Creating fresh settings file...")
        existing = {}
except Exception as e:
    print(f"⚠️  Cannot read existing settings.json: {e}")
    existing = {}

for key, value in new_settings.items():
    if key not in existing:
        existing[key] = value
    elif isinstance(value, list) and isinstance(existing[key], list):
        for item in value:
            if item not in existing[key]:
                existing[key].append(item)
    elif isinstance(value, dict) and isinstance(existing[key], dict):
        for subkey, subvalue in value.items():
            if subkey not in existing[key]:
                existing[key][subkey] = subvalue

with open(settings_file, 'w') as f:
    json.dump(existing, f, indent=2)
print("✅ settings.json updated (existing keys preserved)")
PYEOF
            else
                echo "⚠️  Python not found, skipping settings merge"
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