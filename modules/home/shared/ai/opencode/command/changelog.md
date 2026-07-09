---
description: Generate changelog from git commits
model: opencode/kimi-k2.5
subtask: true
---

Generate a changelog from recent git commits and write it to CHANGELOG.md.

Format changes in these sections:
- **Added**: new features (feat:)
- **Fixed**: bug fixes (fix:)
- **Changed**: refactors, perf improvements
- **Deprecated**: deprecated features
- **Removed**: removed features
- **Security**: security fixes

Group commits logically. Include commit hash (short) for reference.
Use clear, user-friendly descriptions—not technical implementation details.

After generating the changelog content, write it to CHANGELOG.md in the project root.

If CHANGELOG.md already exists:
1. Read the existing file
2. Check which commits are already mentioned by looking at existing commit hashes
3. Only add changelog entries for commits NOT already in the file
4. Prepend new entries at the top, keeping the existing content below
5. Add a date header (e.g., "## 2026-03-09") to group new changes

If CHANGELOG.md doesn't exist, create it with a header like "# Changelog" and add the new entries.

## GIT LOG

!`git log --oneline --no-merges -30`

## LATEST TAG

!`git describe --tags --abbrev=0 2>/dev/null || echo "No tags found"`

## COMMITS SINCE LAST TAG

!`git log --oneline --no-merges $(git describe --tags --abbrev=0 2>/dev/null || echo "HEAD~30")..HEAD 2>/dev/null || echo "Showing last 30 commits"`
