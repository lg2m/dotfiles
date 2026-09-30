# 0012. Refactors are verified as zero-diff

- Status: accepted
- Date: 2026-09-30

## Context

Moving files and rewriting glue can silently change a system.

## Decision

A change labelled *refactor* must not change any host's
`system.build.toplevel.drvPath` (or HM `activationPackage.drvPath`).
Verify with `just drvs > before.txt`, change, `just drvs | diff before.txt -`.

When a change is *intentionally* behavioral, review it with
`just diff <host>` (nvd) and describe the diff in the commit message.

## Consequences

- Structural and behavioral changes land in separate commits.
- Some refactors need tricks (e.g. keeping option order) to stay zero-diff;
  when that's not worth it, reclassify as behavioral and review the diff.
