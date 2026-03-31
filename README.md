# GitHub AI Setup

Set up GitHub Copilot with custom commit message and pull request instructions for your projects.

## What is this?

This repo provides instructions that make GitHub Copilot generate better commit messages and PR descriptions following Conventional Commits format.

## Quick Install (One Command)

```bash
curl -sL https://raw.githubusercontent.com/daesdev/github-ai/main/install.sh | bash
```

## Features

- **Conventional Commits**: Standardized commit message format with type, scope, emoji, and subject
- **PR Descriptions**: Structured template with What/Why/How sections
- **One-command install**: Works on any project with a single curl command

## Installation Methods

### Method 1: curl | bash (Recommended)

```bash
curl -sL https://raw.githubusercontent.com/daesdev/github-ai/main/install.sh | bash
```

### Method 2: Clone and run

```bash
# Clone this repository
git clone https://github.com/daesdev/github-ai.git

# Navigate to your project
cd your-project

# Run the installer
make install
# or
./install.sh
```

### Method 3: Global CLI (Optional)

```bash
# Add to your PATH for global access
export PATH="$PATH:/path/to/github-ai"

# Now you can run from any project
github-ai-setup
```

## What gets installed?

The installer creates these files in your project:

```
.github/ai/
├── commit-message.md    # Commit message instructions
└── pr-description.md    # PR description instructions
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

## Commit Message Format

```
<type>(<scope>): <emoji> <subject>
```

Examples:
- `feat(ui): ✨ Add floating contact button`
- `fix(api): 🐛 Resolve user data fetch timeout`
- `docs: 📝 Update README installation steps`
- `refactor: 🛠️ Simplify authentication flow`

Types: feat ✨, fix 🐛, chore 🔧, refactor 🛠️, docs 📝, style 🎨, test ✅, build 📦, ci 👷, perf ⚡

## PR Description Format

### Title
- Imperative mood, under 50 characters

### Description Sections
- **What changed**: Main modifications
- **Why this change**: Problem being solved
- **How to test**: Testing instructions
- **Additional notes**: Breaking changes, dependencies, etc.

## Update

To update to the latest version, simply run the install command again:

```bash
curl -sL https://raw.githubusercontent.com/daesdev/github-ai/main/install.sh | bash
```

## Uninstall

To remove the AI instruction files (settings remain):

```bash
rm -f .github/ai/commit-message.md .github/ai/pr-description.md
```

Or use Make:

```bash
make uninstall
```

## Requirements

- Git (for clone method)
- Bash
- Python3 (required for JSON merge)
- (Optional) Make

## Contributing

Feel free to submit issues and pull requests to improve the instructions or installer.

## License

MIT