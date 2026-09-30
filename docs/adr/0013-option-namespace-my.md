# 0013. Option namespace `my.*`

- Status: accepted
- Date: 2026-09-30

## Context

Custom options lived under `modules.*` (e.g. `modules.hyprland.enable`).
"modules" is overloaded with the module system itself, and names like
`modules.security` read like upstream options.

## Decision

All custom options live under `my.*`:
`my.hyprland.enable`, `my.ai.opencode.enable`, `my.secrets.sshKeys`, ...

## Consequences

- Grepping `my\.` finds every custom option use.
- No risk of colliding with a future upstream `modules` option.
