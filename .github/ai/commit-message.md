  Downloading commit-message.md...
---
name: 'Conventional Commit Messages'
description: 'Generate commit messages using Conventional Commits format with emoji'
applyTo: '**'
---

# GitHub Copilot Commit Message Instructions

Generate a single commit message for all staged changes using this format:

```
<type>(<scope>): <emoji> <subject>
```

## Format Rules

- **Types**: feat ✨, fix 🐛, chore 🔧, refactor 🛠️, docs 📝, style 🎨, test ✅, build 📦, ci 👷, perf ⚡
- **Scope**: affected area (e.g., ui, api, layout, content), lowercase, never file/component names
- **Emoji**: use the exact emoji from the type
- **Subject**: imperative, clear, max 72 characters, no period

## Examples

- `feat(ui): ✨ Add floating contact button`
- `fix(api): 🐛 Resolve user data fetch timeout`
- `docs: 📝 Update README installation steps`
- `refactor: 🛠️ Simplify authentication flow`
- `chore: 🔧 Update dependencies`

## Optional Sections

**Body**: Explain WHY (not HOW). Leave a blank line after the title.

**Footer**: For breaking changes or issues. Example: `Closes #123`

## Edge Cases

If there are unrelated changes, use a single title and add at the end:
```
NOTE: staged changes include unrelated work; consider splitting commits.
```

## Checklist

- [ ] Single final message
- [ ] First line follows format
- [ ] Valid type, scope, and emoji
- [ ] Imperative subject <= 72 characters
- [ ] No extra text outside commit message
