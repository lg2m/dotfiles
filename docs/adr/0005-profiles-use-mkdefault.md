# 0005. Profiles set options with `mkDefault`

- Status: accepted
- Date: 2026-09-30

## Context

Profiles bundle common choices (e.g. "every workstation has bluetooth and
pipewire"). Hosts must be able to override any of them without `mkForce`.

## Decision

Inside `profiles/**`, every option value is wrapped in `lib.mkDefault`
(or declared via a list/attrset that merges, like `home.packages`).
Profiles are plain modules that are **imported** by hosts, not toggled with an
`enable` option. Profiles may import other profiles.

Hosts set values plainly. `lib.mkForce` in a host is a smell: it usually
means a profile is doing something it shouldn't.

## Consequences

- Host files read as "profiles + deltas".
- Lists merge rather than override, so removing a profile-provided package
  requires not using that profile (or splitting it).
