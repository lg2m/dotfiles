---
description: Remove AI code slop
---

Check the diff against dev, and remove all AI generated slop introduced in this branch.

This includes:

- Extra comments that a human wouldn't add or are inconsistent with the rest of the file
- Decorative comment headers/blocks (e.g., lines of `=`, `-`, `*`, etc.) used as section separators
- Unnecessary defensive checks or error handling that diverges from the codebase's patterns (especially in trusted/validated codepaths)
- Type system workarounds (casts to `any`, `unsafe`, `interface{}` misuse, etc.)
- Any style that is inconsistent with the file or codebase conventions
- Unnecessary emoji usage

Report at the end with only a 1-3 sentence summary of what you changed
