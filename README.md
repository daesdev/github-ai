# VS Code AI Setup

A VS Code configuration tool that sets up GitHub Copilot with custom commit message and pull request instructions using AI.

## What is this?

This is a VS Code configuration tool that modifies your `.vscode/settings.json` to point GitHub Copilot to custom instructions. When you commit or create a PR, Copilot generates optimized messages following Conventional Commits format.

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

.vscode/settings.json           # Updated with Copilot configuration
```

## How It Works

1. Run the install command
2. The script creates `.github/copilot-instructions.md` with your custom AI instructions
3. It updates `.vscode/settings.json` to point GitHub Copilot to the instructions file
4. When you commit or create a PR, Copilot reads your instructions and generates optimized messages

## Requirements

### Software
- **VS Code** - Code editor
- **GitHub Copilot** - Subscription required (not the free tier)

### Tools
- Git
- Bash
- Python3 (required for JSON merge)

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

## Contributing

Feel free to submit issues and pull requests to improve the instructions or installer.

## License

MIT
