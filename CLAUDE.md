# CLAUDE.md — GitHub AI Setup

Context file for AI assistants working on this repository.

## Project Overview

This repository provides installation scripts and configuration files to help developers set up GitHub Copilot with custom commit message and pull request instructions using a single command.

## Purpose

- One-command installation via `curl | bash`
- Standardize commit messages across projects using Conventional Commits
- Generate structured PR descriptions automatically

## Files Structure

```
github-ai/
├── .github/ai/
│   ├── commit-message.md      # Instructions for commit messages
│   └── pr-description.md      # Instructions for PR descriptions
├── .vscode/settings.json      # VS Code Copilot configuration
├── install.sh                 # Installation script (works standalone)
├── Makefile                   # Make commands
├── README.md                  # Usage documentation
└── CLAUDE.md                  # This file
```

## Key Features

### Installation Methods

1. **One-liner (recommended)**:
   ```bash
   curl -sL https://raw.githubusercontent.com/darioesp/github-ai/main/install.sh | bash
   ```

2. **Clone and run**:
   ```bash
   git clone https://github.com/darioesp/github-ai.git
   cd your-project
   make install
   ```

3. **Direct script**:
   ```bash
   ./install.sh
   ```

### install.sh Behavior

- Detects if running from curl pipe or local clone
- Downloads files from GitHub if from curl pipe
- Copies files locally if from cloned repo
- Safely merges settings.json (preserves existing settings)
- Creates backup of files before overwriting

## Key Technologies

- Bash (install.sh) - No external dependencies
- Make
- JSON (settings.json)
- Markdown (instructions files)

## Installation Flow

1. User runs `curl | bash` or `make install`
2. Script creates `.github/ai/` directory in target project
3. Copies instruction .md files (updates if exist)
4. Updates `.vscode/settings.json` with Copilot config (merges, doesn't overwrite)
5. User commits with Conventional Commits format!

## Common Tasks

### Adding a new instruction file

1. Add file to `.github/ai/`
2. Update `install.sh` to copy the new file
3. Update `.vscode/settings.json` with new instruction reference
4. Update README.md with usage example

### Testing installation

```bash
# Create test directory
mkdir -p /tmp/test-project
cd /tmp/test-project

# Test curl method
curl -sL https://raw.githubusercontent.com/darioesp/github-ai/main/install.sh | bash

# Verify files
ls -la .github/ai/
cat .vscode/settings.json
```

### Updating the installer

- Keep install.sh portable (bash, minimal dependencies)
- Test merge logic for settings.json carefully
- Handle edge cases: new project, existing settings, missing directories
- Support both curl pipe and local execution modes

## Edge Cases Handled

- Settings already present → skip merge, notify user
- Python3 available → use for safe JSON merge
- No Python → fallback to basic merge
- Already has .github/ai/ with other files → preserve other files
- First run vs update → both handled gracefully