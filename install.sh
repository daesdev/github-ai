#!/bin/bash

# GitHub AI Setup - Single Command Installer
# Usage: curl -sL https://raw.githubusercontent.com/darioesp/github-ai/main/install.sh | bash
# Or:   curl -sL https://bit.ly/github-ai-setup | bash

set -e

echo "🚀 GitHub AI Setup"

# Detect if running from pipe (curl | bash) or direct execution
detect_source() {
    if [ -n "$GITHUB_AI_SOURCE_URL" ]; then
        echo "$GITHUB_AI_SOURCE_URL"
    elif [ -f "${BASH_SOURCE[0]}" ] && grep -q "GITHUB_AI_SOURCE_URL" "${BASH_SOURCE[0]}" 2>/dev/null; then
        # Running as downloaded script
        echo "https://raw.githubusercontent.com/darioesp/github-ai/main"
    else
        # Running from cloned repo
        echo "local"
    fi
}

SOURCE_TYPE=$(detect_source)

install_from_url() {
    local base_url="$1"
    local temp_dir=$(mktemp -d)
    
    echo "📥 Downloading files from GitHub..."
    
    # Download files
    curl -sL "$base_url/.github/ai/commit-message.md" -o "$temp_dir/commit-message.md" || {
        echo "❌ Failed to download commit-message.md"
        exit 1
    }
    
    curl -sL "$base_url/.github/ai/pr-description.md" -o "$temp_dir/pr-description.md" || {
        echo "❌ Failed to download pr-description.md"
        exit 1
    }
    
    curl -sL "$base_url/.vscode/settings.json" -o "$temp_dir/settings.json" || {
        echo "❌ Failed to download settings.json"
        exit 1
    }
    
    # Create .github/ai directory
    mkdir -p .github/ai
    
    # Copy files
    echo "📄 Installing instruction files..."
    cp -f "$temp_dir/commit-message.md" .github/ai/
    cp -f "$temp_dir/pr-description.md" .github/ai/
    
    # Handle settings.json
    mkdir -p .vscode
    
    if [ -f ".vscode/settings.json" ]; then
        echo "📝 Merging with existing settings.json..."
        
        if grep -q "github.copilot.chat.commitMessageGeneration.instructions" .vscode/settings.json; then
            echo "⚠️  Settings already present, skipping..."
        else
            # Use Python for safe JSON merge if available, otherwise use simple merge
            if command -v python3 &> /dev/null; then
                python3 - "$temp_dir/settings.json" << 'PYEOF'
import json, sys
settings_file = '.vscode/settings.json'
new_settings = json.load(open(sys.argv[1]))
existing = json.load(open(settings_file)) if settings_file.exists() else {}
existing.update(new_settings)
with open(settings_file, 'w') as f:
    json.dump(existing, f, indent=2)
print("✅ Updated settings.json")
PYEOF
            else
                # Fallback: simple concatenation (less safe)
                echo ", $(cat "$temp_dir/settings.json" | tail -n +2)" | head -c -2 > .vscode/settings.json.tmp
                cat .vscode/settings.json .vscode/settings.json.tmp > .vscode/settings.json.new 2>/dev/null || true
                mv .vscode/settings.json.new .vscode/settings.json 2>/dev/null || true
                echo "✅ Updated settings.json (basic merge)"
            fi
        fi
    else
        cp -f "$temp_dir/settings.json" .vscode/settings.json
        echo "✅ Created settings.json"
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
    
    echo ""
    echo "✅ Installation complete!"
    echo ""
    echo "Your project now has:"
    echo "  - .github/ai/commit-message.md"
    echo "  - .github/ai/pr-description.md"
    echo "  - .vscode/settings.json"
    echo ""
    echo "Commit messages will now follow Conventional Commits format!"
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
        
        if grep -q "github.copilot.chat.commitMessageGeneration.instructions" .vscode/settings.json; then
            echo "⚠️  Settings already present, skipping..."
        else
            if command -v python3 &> /dev/null; then
                python3 - "$script_dir/.vscode/settings.json" << 'PYEOF'
import json, sys
settings_file = '.vscode/settings.json'
new_settings = json.load(open(sys.argv[1]))
existing = json.load(open(settings_file)) if settings_file.exists() else {}
existing.update(new_settings)
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
    
    echo ""
    echo "✅ Installation complete!"
}

# Run appropriate installation
if [ "$SOURCE_TYPE" = "local" ]; then
    install_from_local
else
    install_from_url "$SOURCE_TYPE"
fi

echo ""
echo "To update in the future, run the same command again."