# GitHub AI Setup

Set up GitHub Copilot with custom commit message and pull request instructions for your projects using AI.

## What is this?

This repo provides instructions that make GitHub Copilot generate better commit messages and PR descriptions following Conventional Commits format using AI-powered generation.

## Quick Install (One Command)

```bash
curl -sL https://raw.githubusercontent.com/daesdev/github-ai/main/install.sh | bash
```

## Features

- **AI-Powered Commit Messages**: GitHub Copilot generates commit messages using Conventional Commits format with AI
- **AI-Powered PR Descriptions**: Intelligent PR title and description generation with structured templates
- **Conventional Commits**: Standardized commit message format with type, scope, emoji, and subject
- **One-command install**: Works on any project with a single curl command
- **Safe & Secure**: Backup to `~/.daes/` before any modification, restores on failure
- **Version Tracking**: Shows current version during installation, auto-updates landing page on release

## Installation Methods

### Method 1: curl | bash (Recommended)

```bash
curl -sL https://raw.githubusercontent.com/daesdev/github-ai/main/install.sh | bash
```

### Method 2: Clone and run

```bash
git clone https://github.com/daesdev/github-ai.git
cd your-project
make install
# or
./install.sh
```

## What gets installed?

The installer creates these files in your project:

```
.github/
└── copilot-instructions.md    # AI instructions for commits and PRs
```

And adds this to `.vscode/settings.json`:

```json
{
  "github.copilot.chat.commitMessageGeneration.instructions": [
    {
      "file": ".github/copilot-instructions.md"
    }
  ],
  "github.copilot.chat.pullRequestDescriptionGeneration.instructions": [
    {
      "file": ".github/copilot-instructions.md"
    }
  ]
}
```

## How It Works

GitHub Copilot uses the instruction file to generate:
- **Commit Messages**: AI-generated messages following Conventional Commits format
- **PR Descriptions**: AI-generated titles and descriptions with structured templates

The settings point Copilot to `.github/copilot-instructions.md`.

## Backup & Safety

Before modifying `.vscode/settings.json`, the installer:
1. Creates a backup in `~/.daes/` with timestamp
2. Only adds new keys if they don't exist (preserves existing settings)
3. Restores from backup if something fails

## Landing Page

The project includes a landing page at `web/index.html` that displays:
- Installation command
- Features overview
- Version badge (auto-updates on release via GitHub Actions)

### Deploy to Cloudflare Pages

```bash
# Install wrangler if needed
npm install -g wrangler

# Deploy to Cloudflare Pages
wrangler pages deploy web --project-name=github-ai
```

The landing page will be available at `vscode.daes.dev`

## Requirements

- Git (for clone method)
- Bash
- Python3 (required for JSON merge)
- (Optional) Make

## Contributing

Feel free to submit issues and pull requests to improve the instructions or installer.

## License

MIT