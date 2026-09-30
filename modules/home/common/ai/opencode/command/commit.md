---
description: git commit and push
model: opencode/kimi-k2.5
subtask: true
---

Commit and push changes.

Use conventional commits with these prefixes:
- feat: new features
- fix: bug fixes
- docs: documentation
- style: formatting (no code change)
- refactor: code restructuring
- perf: performance improvements
- test: tests
- chore: build/tooling changes

Format: `<type>(<scope>): <description>`
- Breaking: `<type>!: <description>` or `<type>(<scope>)!: <description>`

Explain WHY from a user perspective, not WHAT.
Be specific—no generic messages like "improved experience".

If conflicts exist, STOP and notify me.

## GIT DIFF

!`git diff`

## GIT DIFF --cached

!`git diff --cached`

## GIT STATUS --short

!`git status --short`
