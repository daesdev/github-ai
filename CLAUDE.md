# CLAUDE.md — GitHub AI Setup

Context file for AI assistants working on this repository.

## Project Overview

This repository provides installation scripts and configuration files to help developers set up GitHub Copilot with custom commit message and pull request instructions using AI-powered generation.

## Purpose

- One-command installation via `curl | bash`
- AI-powered commit messages following Conventional Commits format
- AI-powered PR descriptions with structured templates

## Files Structure

```
github-ai/
├── .github/
│   ├── ai/
│   │   ├── commit-message.md      # AI instructions for commit messages
│   │   └── pr-description.md      # AI instructions for PR descriptions
│   └── workflows/
│       └── update-website.yml     # Auto-update version badge on release
├── .vscode/settings.json           # VS Code Copilot configuration
├── web/index.html                  # Landing page with version badge
├── wrangler.jsonc                  # Cloudflare Pages deployment config
├── install.sh                      # Installation script (works standalone)
├── Makefile                        # Make commands
├── README.md                       # Usage documentation
└── CLAUDE.md                       # This file
```

## Key Features

### Installation Methods

1. **One-liner (recommended)**:
   ```bash
   curl -sL https://raw.githubusercontent.com/daesdev/github-ai/main/install.sh | bash
   ```

2. **Clone and run**:
   ```bash
   git clone https://github.com/daesdev/github-ai.git
   cd your-project
   make install
   ```

### install.sh Behavior

- Detects if running from curl pipe or local clone
- Downloads files from GitHub if from curl pipe
- Copies files locally if from cloned repo
- Creates backup before modifying `.vscode/settings.json` (`~/.daes/`)
- Creates local `.bak` file for safety
- Merges settings.json preserving existing keys
- Restores from backup if something fails
- Fetches latest version from GitHub API (`get_latest_version()`)
- Shows version at end of installation

## Key Technologies

- Bash (install.sh)
- Python3 (required for JSON merge)
- Make
- JSON (settings.json)
- Markdown (instructions files)
- Wrangler (Cloudflare Pages deployment)
- GitHub Actions (auto-update version on release)

## Deployment

### Cloudflare Pages
The project uses Cloudflare Pages for hosting the landing page at `vscode.daes.dev`.

**Wrangler config** (`wrangler.jsonc`):
- Project name: `github-ai`
- Environment: production
- Custom domain: `vscode.daes.dev`

**Deploy commands**:
```bash
# Install wrangler if needed
npm install -g wrangler

# Deploy to Cloudflare Pages
wrangler pages deploy web --project-name=github-ai
```

### GitHub Actions
- `update-website.yml`: Auto-updates version badge in `web/index.html` on release

## VS Code Settings Keys

The installer adds these keys to `.vscode/settings.json`:

- `github.copilot.chat.commitMessageGeneration.instructions` - AI instructions for commit messages
- `github.copilot.chat.pullRequestDescriptionGeneration.instructions` - AI instructions for PR descriptions

Both use the format: `[{"file": ".github/ai/commit-message.md"}]`

## Installation Flow

1. User runs `curl | bash` or `make install`
2. Script creates `.github/ai/` directory in target project
3. Copies instruction .md files (updates if exist)
4. Backs up existing `.vscode/settings.json` to `~/.daes/`
5. Merges Copilot instruction keys into settings.json (preserves existing)
6. User commits with AI-generated Conventional Commits format!

## Common Tasks

### Adding a new instruction file

1. Add file to `.github/ai/`
2. Update `install.sh` to copy the new file
3. Update `configure_vscode_settings()` with new instruction key
4. Update README.md with usage example

### Testing installation

```bash
# Test curl method
curl -sL https://raw.githubusercontent.com/daesdev/github-ai/main/install.sh | bash

# Verify files
ls -la .github/ai/
cat .vscode/settings.json
```

### Restoring backup

Backups are stored in `~/.daes/` with timestamp format: `settings_YYYYMMDD_HHMMSS.json`

## Backup & Safety Functions

The installer provides these functions for safe modifications:

- `backup_settings()` - Creates backup in `~/.daes/` with timestamp
- `restore_settings()` - Restores from latest backup if something fails
- `configure_vscode_settings()` - Main function that handles all VS Code settings

All modifications to `settings.json`:
1. Create backup in `~/.daes/settings_YYYYMMDD_HHMMSS.json`
2. Create local `.bak` file
3. Only add keys if they don't exist (merge, not replace)
4. Restore from backup if Python script fails

## Edge Cases Handled

- Settings already present → merges, preserves existing keys
- Python3 not available → exits with error
- Invalid JSON in settings.json → uses backup or starts fresh
- Network failure during curl → shows error and exits
- Missing source files (local mode) → exits with error
- Script interruption → cleanup temp files via trap

## Release Process

### Version Format
`v[year-short].[month-number].[day-number][hours-format24]`
- Example: `v26.03.31.13` (year: 2026, month: 03, day: 31, hour: 13)

### Steps to Create Release

1. **Delete old tags locally and remotely**:
```bash
git tag -l                          # List current tags
git tag -d <tag1> <tag2> ...        # Delete local tags
git push origin --delete <tag1> <tag2>...  # Delete remote tags
```

2. **Generate new version**:
```bash
date +"v%y.%m.%d.%H"               # Generate version format
```

3. **Create release using git flow**:
```bash
git flow release start <version>    # Create release branch
git flow release finish -m "v<version>" <version>  # Finish release
```

4. **Push to origin**:
```bash
git push -u origin main develop --tags
```

5. **Create GitHub Release** (if gh has workflow scope):
```bash
gh auth refresh -h github.com -s workflow  # If needed
gh release create <version> --title "<version>" --notes "<description>"
```

### Important Notes
- Always use git flow for releases
- Delete old tags before creating new ones
- Format: vYY.MM.DD.HH (24-hour format for hours)
- Requires `workflow` scope in gh auth to create GitHub releases