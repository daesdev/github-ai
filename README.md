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
.github/ai/
├── commit-message.md    # Commit message AI instructions
└── pr-description.md    # PR description AI instructions
```

And adds this to `.vscode/settings.json`:

```json
{
  "github.copilot.chat.commitMessageGeneration.instructions": [
    {
      "file": ".github/ai/commit-message.md"
    }
  ],
  "github.copilot.chat.pullRequestDescriptionGeneration.instructions": [
    {
      "file": ".github/ai/pr-description.md"
    }
  ]
}
```

## How It Works

GitHub Copilot uses the instruction files to generate:
- **Commit Messages**: AI-generated messages following Conventional Commits format
- **PR Descriptions**: AI-generated titles and descriptions with structured templates

The settings point Copilot to the instruction files in `.github/ai/`.

## Backup & Safety

Before modifying `.vscode/settings.json`, the installer:
1. Creates a backup in `~/.daes/` with timestamp
2. Creates a local `.bak` file
3. Only adds new keys if they don't exist (preserves existing settings)
4. Restores from backup if something fails

## Requirements

- Git (for clone method)
- Bash
- Python3 (required for JSON merge)
- (Optional) Make

## Contributing

Feel free to submit issues and pull requests to improve the instructions or installer.

## License

MIT