#!/bin/bash

# GitHub AI Setup - Single Command Installer
# Usage: curl -sL https://raw.githubusercontent.com/daesdev/github-ai/main/install.sh | bash

set -e

echo "🚀 GitHub AI Setup"

# Default base URL
BASE_URL="${GITHUB_AI_BASE_URL:-https://raw.githubusercontent.com/daesdev/github-ai/main}"

# ─── FIX #1: Cleanup automático si el script es interrumpido ───────────────────
TEMP_DIR=""
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}
trap cleanup EXIT INT TERM

# ─── FIX #2: Detección de pipe clara y sin ambigüedad ─────────────────────────
is_pipe() {
    # Retorna 0 (true) si stdin NO es un terminal => se está ejecutando via pipe
    [ ! -t 0 ]
}

# ─── FIX #3: Descarga separando declaración y asignación (respeta set -e) ──────
download_file() {
    local url="$1"
    local label="$2"
    local content

    echo "  Downloading ${label}..."
    content=$(curl -sL --fail "$url") || {
        echo "❌ Error: Could not download ${label} from ${url}"
        exit 1
    }

    if echo "$content" | grep -q "404: Not Found\|404 Not Found"; then
        echo "❌ Error: ${label} returned 404 at ${url}"
        exit 1
    fi

    echo "$content"
}

install_from_github() {
    TEMP_DIR=$(mktemp -d)

    echo "📥 Downloading files from GitHub..."

    # FIX #3 aplicado: declaración separada de asignación
    local commit_file
    commit_file=$(download_file "$BASE_URL/.github/ai/commit-message.md" "commit-message.md")
    echo "$commit_file" > "$TEMP_DIR/commit-message.md"

    local pr_file
    pr_file=$(download_file "$BASE_URL/.github/ai/pr-description.md" "pr-description.md")
    echo "$pr_file" > "$TEMP_DIR/pr-description.md"

    # Crear directorios e instalar
    mkdir -p .github/ai

    echo "📄 Installing instruction files..."
    cp -f "$TEMP_DIR/commit-message.md" .github/ai/
    cp -f "$TEMP_DIR/pr-description.md" .github/ai/
    echo "  ✅ Installed .github/ai/commit-message.md"
    echo "  ✅ Installed .github/ai/pr-description.md"

    echo "📝 Configuring VS Code settings..."
    configure_vscode_settings

    # Cleanup explícito (el trap también lo hará, pero es prolijo hacerlo acá)
    rm -rf "$TEMP_DIR"
    TEMP_DIR=""
}

install_from_local() {
    # FIX #4: Resolución robusta del directorio del script
    local script_dir
    if [ -n "${BASH_SOURCE[0]:-}" ]; then
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    else
        script_dir="$(cd "$(dirname "$0")" && pwd)"
    fi

    # FIX #5: Verificar que los archivos fuente existen antes de copiar
    local missing=0
    for f in ".github/ai/commit-message.md" ".github/ai/pr-description.md"; do
        if [ ! -f "$script_dir/$f" ]; then
            echo "❌ Missing source file: $script_dir/$f"
            missing=1
        fi
    done
    [ "$missing" -eq 1 ] && exit 1

    mkdir -p .github/ai

    echo "📄 Installing instruction files..."
    cp -f "$script_dir/.github/ai/commit-message.md" .github/ai/
    cp -f "$script_dir/.github/ai/pr-description.md" .github/ai/
    echo "  ✅ Installed .github/ai/commit-message.md"
    echo "  ✅ Installed .github/ai/pr-description.md"

    echo "📝 Configuring VS Code settings..."
    configure_vscode_settings
}

configure_vscode_settings() {
    mkdir -p .vscode

    if [ ! -f ".vscode/settings.json" ]; then
        # No existe: crear desde cero
        _write_vscode_settings_new
    else
        # Existe: hacer backup y mergear
        local backup_dir="$HOME/.daes"
        mkdir -p "$backup_dir"
        local timestamp
        timestamp=$(date +"%Y%m%d_%H%M%S")
        cp -f .vscode/settings.json "$backup_dir/settings_${timestamp}.json"
        echo "  ✅ Backed up settings.json → $backup_dir/settings_${timestamp}.json"

        _write_vscode_settings_merge
    fi
}

# ─── FIX #6: Heredocs de Python extraídos a funciones propias ─────────────────
# Esto evita problemas de parsing de heredocs anidados en if/else
_write_vscode_settings_new() {
    if ! command -v python3 &> /dev/null; then
        echo "  ⚠️  python3 not found — skipping VS Code settings"
        return
    fi

    python3 - << 'PYEOF'
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

print("  ✅ Created .vscode/settings.json")
PYEOF
}

_write_vscode_settings_merge() {
    if ! command -v python3 &> /dev/null; then
        echo "  ⚠️  python3 not found — skipping VS Code settings merge"
        return
    fi

    python3 - << 'PYEOF'
import json, sys

settings_file = '.vscode/settings.json'
backup_file   = settings_file + '.bak'

commit_key   = "github.copilot.chat.commitMessageGeneration.instructions"
commit_value = [{"file": ".github/ai/commit-message.md"}]

pr_key   = "github.copilot.chat.pullRequestDescriptionGeneration.instructions"
pr_value = [{"file": ".github/ai/pr-description.md"}]

# Backup antes de modificar
try:
    with open(settings_file, 'r') as f:
        original = f.read()
    with open(backup_file, 'w') as f:
        f.write(original)
except Exception as e:
    print(f"  ⚠️  Could not create .bak: {e}", file=sys.stderr)

# Cargar JSON existente
try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)
except json.JSONDecodeError:
    print("  ⚠️  settings.json has invalid JSON — starting fresh")
    settings = {}
except Exception as e:
    print(f"  ⚠️  Could not read settings.json: {e} — starting fresh")
    settings = {}

# Agregar claves solo si no existen
for key, value, label in [
    (commit_key, commit_value, "commitMessageGeneration"),
    (pr_key,     pr_value,     "pullRequestDescriptionGeneration"),
]:
    if key not in settings:
        settings[key] = value
        print(f"  ✅ Added: {label}")
    else:
        print(f"  ⏭️  Skipped (already exists): {label}")

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print("  ✅ VS Code settings updated")
PYEOF
}

# ─── Entry point ──────────────────────────────────────────────────────────────
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