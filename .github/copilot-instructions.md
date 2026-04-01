---
name: Project Rules
description: Instructions for commits and PRs
---

# Commit Message Rules

- Use Conventional Commits format (feat ✨, fix 🐛, etc.).
- Format: `<type>(<scope>): <emoji> <subject>`

## Allowed Types

- **feat ✨**: New features
- **fix 🐛**: Bug fixes
- **chore 🔧**: Maintenance tasks
- **refactor 🛠️**: Code refactoring
- **docs 📝**: Documentation
- **style 🎨**: Styles (formatting)
- **test ✅**: Tests
- **build 📦**: Build and dependencies
- **ci 👷**: CI/CD configuration
- **perf ⚡**: Performance optimizations

## Examples

- `feat(ui): ✨ Add floating contact button`
- `fix(api): 🐛 Resolve user data fetch timeout`
- `docs: 📝 Update README installation steps`
- `refactor: 🛠️ Simplify authentication flow`
- `chore: 🔧 Update dependencies`

## Additional Rules

- **Scope**: Affected area (ui, api, layout, content), lowercase
- **Subject**: Imperative, clear, maximum 72 characters, no period at the end
- **Body**: Explain the WHY (not the HOW). Leave a blank line after the title
- **Footer**: For breaking changes or issues. Example: `Closes #123`

## Special Cases

If there are unrelated changes, use a single title and add at the end:

```
NOTE: staged changes include unrelated work; consider splitting commits.
```

---

# Pull Request Rules

- Always include a "Key Changes" section.
- Title in imperative mood, less than 50 characters.
- Description following What/Why/How structure.

## PR Structure

### Title

- Use imperative mood (e.g., "Add feature" not "Added feature")
- Keep it under 50 characters
- Be specific about what changed

### Description

**Key Changes**: What was modified

- List the main modifications
- Explain the purpose of each change

**Why**: Problem it solves

- Describe the problem being solved
- Reference related issues (e.g., `Fixes #123`, `Closes #456`)

**How to Test**: Testing instructions

- Provide step-by-step instructions
- Include expected results

**Additional Notes** (optional):

- Breaking changes
- Dependencies added/removed
- Necessary configuration changes
- Related PRs or documentation
