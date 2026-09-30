# 0001. Record architecture decisions

- Status: accepted
- Date: 2026-09-30

## Context

This repo configures several machines across NixOS, nix-darwin and standalone
Home Manager. Structural choices (where things live, how secrets work, how
hosts are built) are easy to forget and easy to erode one "quick fix" at a time.

## Decision

Record significant decisions as short ADRs in `docs/adr/`, numbered
sequentially, using [`template.md`](template.md). An ADR is never edited to
change its meaning; it is superseded by a new one.

Write an ADR when a change:

- adds or removes a layer, directory convention or flake input category,
- changes how secrets, keys or deployment work,
- establishes a rule other contributors (human or agent) must follow.

## Consequences

- New contributors and AI agents can learn *why* from `docs/adr/`.
- Small cost per decision; skip it for routine package/option changes.
