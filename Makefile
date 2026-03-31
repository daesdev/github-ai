.PHONY: install uninstall update help

help:
	@echo "GitHub AI Setup - Conventional Commits for Copilot"
	@echo ""
	@echo "Usage:"
	@echo "  make install    - Install AI instructions to current project"
	@echo "  make update    - Update to latest version from GitHub"
	@echo "  make uninstall - Remove AI instruction files (keep settings)"
	@echo "  make help      - Show this help message"
	@echo ""
	@echo "Quick install (one command):"
	@echo "  curl -sL https://raw.githubusercontent.com/darioesp/github-ai/main/install.sh | bash"

install:
	@./install.sh

update:
	@echo "🔄 Updating from GitHub..."
	@curl -sL https://raw.githubusercontent.com/darioesp/github-ai/main/.github/ai/commit-message.md -o .github/ai/commit-message.md
	@curl -sL https://raw.githubusercontent.com/darioesp/github-ai/main/.github/ai/pr-description.md -o .github/ai/pr-description.md
	@echo "✅ Updated instruction files"

uninstall:
	@echo "🗑️  Removing AI instruction files..."
	@rm -f .github/ai/commit-message.md .github/ai/pr-description.md
	@echo "✅ Removed instruction files from .github/ai/"
	@echo ""
	@echo "Note: The .github/ai directory remains. Copilot settings in .vscode/settings.json are preserved."