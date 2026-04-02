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

get_latest_version() {
    local version
    version=$(curl -sL --fail "https://api.github.com/repos/daesdev/github-ai/tags" 2>/dev/null | grep -o '"name": "[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -n "$version" ]; then
        echo "$version"
    else
        echo "latest"
    fi
}

get_install_version() {
    if [ -n "$GITHUB_AI_VERSION" ]; then
        echo "$GITHUB_AI_VERSION"
    else
        get_latest_version
    fi
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
import re
import shutil
from datetime import datetime

settings_file = '.vscode/settings.json'
backup_file = settings_file + '.bak'

def strip_json_comments(content):
    content = re.sub(r'//.*$', '', content, flags=re.MULTILINE)
    content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
    return content

commit_key = "github.copilot.chat.commitMessageGeneration.instructions"
commit_value = [{"file": ".github/copilot-instructions.md"}]

pr_key = "github.copilot.chat.pullRequestDescriptionGeneration.instructions"
pr_value = [{"file": ".github/copilot-instructions.md"}]

settings = {}
original_content = ""

if os.path.exists(settings_file):
    try:
        with open(settings_file, 'r') as f:
            original_content = f.read().strip()
            if original_content:
                shutil.copy(settings_file, backup_file)
                content = strip_json_comments(original_content)
                settings = json.loads(content)
    except json.JSONDecodeError as e:
        print(f"  ⚠️  Invalid JSON (with comments): {e}")
        if os.path.exists(backup_file):
            try:
                with open(backup_file, 'r') as f:
                    original_content = f.read().strip()
                    content = strip_json_comments(original_content)
                    settings = json.loads(content)
                print("  ✅ Fixed JSON by stripping comments, preserved content")
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
    if os.path.exists(backup_file):
        try:
            with open(backup_file, 'r') as f:
                settings = json.load(f)
            with open(settings_file, 'w') as f:
                json.dump(settings, f, indent=2)
            print("  ⚠️  Restored settings from backup")
        except:
            pass
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

    echo "  Downloading ${label}..." >&2
    local content
    content=$(curl -sL --fail "$url") || {
        echo "  ❌ Error: Could not download ${label}" >&2
        exit 1
    }

    if echo "$content" | grep -q "404"; then
        echo "  ❌ Error: ${label} not found" >&2
        exit 1
    fi

    echo "$content"
}

install_from_github() {
    TEMP_DIR=$(mktemp -d)

    echo "📥 Downloading files from GitHub..."

    local instructions_file
    instructions_file=$(download_file "$BASE_URL/.github/copilot-instructions.md" "copilot-instructions.md")
    echo "$instructions_file" > "$TEMP_DIR/copilot-instructions.md"
    echo "  ✅ Downloaded copilot-instructions.md"

    mkdir -p .github

    echo "📄 Installing instruction files..."
    cp -f "$TEMP_DIR/copilot-instructions.md" .github/
    echo "  ✅ Installed .github/copilot-instructions.md"

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

    if [ ! -f "$script_dir/.github/copilot-instructions.md" ]; then
        echo "❌ Missing source file: $script_dir/.github/copilot-instructions.md"
        exit 1
    fi

    mkdir -p .github

    echo "📄 Installing instruction files..."
    cp -f "$script_dir/.github/copilot-instructions.md" .github/
    echo "  ✅ Installed .github/copilot-instructions.md"

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
echo "  - .github/copilot-instructions.md"
echo "  - .vscode/settings.json (with Copilot AI instructions)"
echo ""
echo "📦 Backup location: $HOME/.daes/settings_*.json"
echo ""
echo "Commit messages will now follow Conventional Commits format!"
echo ""
echo "Version: $(get_install_version)"
echo ""
echo "To update in the future, run:"
echo "  curl -sL $BASE_URL/install.sh | bash"