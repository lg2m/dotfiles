# 0004. Module contract and explicit imports

- Status: accepted
- Date: 2026-09-30

## Context

Directories were auto-imported with `builtins.readDir`, including host
directories. That made it possible to change a host's behavior by merely
dropping a file into a folder (e.g. `waygate-enable.nix`), which is invisible
when reading the host's `default.nix`.

## Decision

1. **Every module under `modules/` is inert by default.** It declares options
   under `my.*` and only emits config inside `lib.mkIf cfg.enable`.
2. **Module libraries are imported wholesale** by `lib/` (via an
   `importTree` helper). Because they're inert, this is safe and means options
   are always available.
3. **Hosts and profiles import explicitly.** No `readDir` in `hosts/` or
   `profiles/`. What a host does is visible in `hosts/<name>/default.nix`.
4. One module per directory (`<name>/default.nix`) or file (`<name>.nix`);
   extra assets (configs, themes) live beside it.

## Consequences

- Reading a host file tells you everything it enables.
- A new module is available everywhere as soon as it's created, but does
  nothing until something enables it.
