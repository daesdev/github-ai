#!/bin/bash

# GitHub AI Setup - Single Command Installer
# Usage: curl -sL https://raw.githubusercontent.com/daesdev/github-ai/main/install.sh | bash

set -e

echo "🚀 GitHub AI Setup"

BASE_URL="${GITHUB_AI_BASE_URL:-https://raw.githubusercontent.com/daesdev/github-ai/main}"

TEMP_DIR=""
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT INT TERM

is_pipe() {
    [ ! -t 0 ]
}

backup_settings() {
    if [ -f ".vscode/settings.json" ]; then
        BACKUP_DIR="$HOME/.daes"
        mkdir -p "$BACKUP_DIR"
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        cp -f .vscode/settings.json "$BACKUP_DIR/settings_${TIMESTAMP}.json"
        echo "  ✅ Backed up settings.json to $BACKUP_DIR"
        return 0
    fi
    return 1
}

restore_settings() {
    BACKUP_DIR="$HOME/.daes"
    LATEST=$(ls -t "$BACKUP_DIR"/settings_*.json 2>/dev/null | head -1)
    if [ -n "$LATEST" ]; then
        cp -f "$LATEST" .vscode/settings.json
        echo "  ✅ Restored settings.json from backup"
    fi
}

configure_vscode_settings() {
    mkdir -p .vscode
    
    backup_settings || true
    
    if ! command -v python3 &> /dev/null; then
        echo "  ❌ Python3 not found. Cannot configure VS Code settings."
        exit 1
    fi
    
    python3 - << 'PYEOF'
import json
import os
import sys

settings_file = '.vscode/settings.json'
backup_file = settings_file + '.bak'

commit_key = "github.copilot.chat.commitMessageGeneration.instructions"
commit_value = [{"file": ".github/ai/commit-message.md"}]

pr_key = "github.copilot.chat.pullRequestDescriptionGeneration.instructions"
pr_value = [{"file": ".github/ai/pr-description.md"}]

settings = {}
if os.path.exists(settings_file):
    try:
        with open(settings_file, 'r') as f:
            content = f.read().strip()
            if content:
                settings = json.loads(content)
    except json.JSONDecodeError:
        if os.path.exists(backup_file):
            try:
                with open(backup_file, 'r') as f:
                    settings = json.load(f)
                print("  ⚠️  Invalid JSON, restored from backup")
            except:
                settings = {}
        else:
            settings = {}
    except Exception as e:
        print(f"  ⚠️  Error reading settings.json: {e}")
        settings = {}

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

try:
    with open(settings_file, 'w') as f:
        json.dump(settings, f, indent=2)
    print("✅ VS Code settings configured")
except Exception as e:
    print(f"  ❌ Error writing settings.json: {e}")
    sys.exit(1)
PYEOF
    
    if [ $? -ne 0 ]; then
        echo "  ❌ Failed to configure settings, restoring backup..."
        restore_settings
        exit 1
    fi
}

download_file() {
    local url="$1"
    local label="$2"
    local content
    
    echo "  Downloading ${label}..."
    content=$(curl -sL --fail "$url") || {
        echo "  ❌ Error: Could not download ${label}"
        exit 1
    }
    
    if echo "$content" | grep -q "404"; then
        echo "  ❌ Error: ${label} not found"
        exit 1
    fi
    
    echo "$content"
}

install_from_github() {
    TEMP_DIR=$(mktemp -d)
    
    echo "📥 Downloading files from GitHub..."
    
    local commit_file
    commit_file=$(download_file "$BASE_URL/.github/ai/commit-message.md" "commit-message.md")
    echo "$commit_file" > "$TEMP_DIR/commit-message.md"
    echo "  ✅ Downloaded commit-message.md"
    
    local pr_file
    pr_file=$(download_file "$BASE_URL/.github/ai/pr-description.md" "pr-description.md")
    echo "$pr_file" > "$TEMP_DIR/pr-description.md"
    echo "  ✅ Downloaded pr-description.md"
    
    mkdir -p .github/ai
    
    echo "📄 Installing instruction files..."
    cp -f "$TEMP_DIR/commit-message.md" .github/ai/
    cp -f "$TEMP_DIR/pr-description.md" .github/ai/
    echo "  ✅ Installed .github/ai/commit-message.md"
    echo "  ✅ Installed .github/ai/pr-description.md"
    
    echo "📝 Configuring VS Code settings..."
    configure_vscode_settings
}

install_from_local() {
    local script_dir
    if [ -n "${BASH_SOURCE[0]:-}" ]; then
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    else
        script_dir="$(cd "$(dirname "$0")" && pwd)"
    fi
    
    for f in ".github/ai/commit-message.md" ".github/ai/pr-description.md"; do
        if [ ! -f "$script_dir/$f" ]; then
            echo "❌ Missing source file: $script_dir/$f"
            exit 1
        fi
    done
    
    mkdir -p .github/ai
    
    echo "📄 Installing instruction files..."
    cp -f "$script_dir/.github/ai/commit-message.md" .github/ai/
    cp -f "$script_dir/.github/ai/pr-description.md" .github/ai/
    echo "  ✅ Installed .github/ai/commit-message.md"
    echo "  ✅ Installed .github/ai/pr-description.md"
    
    echo "📝 Configuring VS Code settings..."
    configure_vscode_settings
}

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
echo "  - .vscode/settings.json (with Copilot AI instructions)"
echo ""
echo "📦 Backup location: $HOME/.daes/settings_*.json"
echo ""
echo "Commit messages will now follow Conventional Commits format!"
echo ""
echo "To update in the future, run:"
echo "  curl -sL $BASE_URL/install.sh | bash"