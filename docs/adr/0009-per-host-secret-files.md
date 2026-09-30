# 0009. Secret files are scoped per host

- Status: accepted
- Date: 2026-09-30

## Context

A single secrets file encrypted to every host means any compromised machine
leaks every secret.

## Decision

```
secrets/
  common.yaml          # admin + all system hosts (use sparingly)
  hosts/<host>.yaml    # admin + that host only
  home/<host>.yaml     # admin + that standalone-HM host only
```

`.sops.yaml` creation rules enforce the recipients by path. A secret goes in
`common.yaml` only if every host genuinely needs the same value.

## Consequences

- Per-host SSH keys, tokens and passwords are isolated.
- A secret shared by two (not all) hosts is duplicated into both files.
