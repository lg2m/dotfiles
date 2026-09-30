# 0010. Remote deploy with `--target-host`

- Status: accepted
- Date: 2026-09-30

## Context

mimir is headless-ish and a CI runner host; switching it means SSHing in,
pulling the repo and rebuilding there.

## Decision

Deploy remotely with the built-in `nixos-rebuild --target-host` (wrapped as
`just deploy <host>`). Build locally by default; `--build-host` is available
when the target is stronger. The target is read from `inventory.nix`
(`deploy.target`).

## Consequences

- No extra flake inputs or schemas.
- No automatic "magic rollback" if a deploy breaks networking; mitigated by
  `just deploy-test` (activates without adding a boot entry, so a reboot
  recovers).

## Alternatives considered

- **deploy-rs.** Magic rollback is nice, but it's another input and schema.
- **comin (pull-based GitOps).** Good for fleets; overkill for a few boxes.
