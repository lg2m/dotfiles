# 0003. Platform split

- Status: accepted
- Date: 2026-09-30

## Context

All Home Manager modules lived in `modules/home/shared`, including
Linux-only ones (Hyprland, Helium, `wl-copy` aliases). Adding macOS would make
"shared" meaningless.

## Decision

Split modules by the platform they can run on:

```
modules/
  common/        # system-level, valid on NixOS *and* nix-darwin
  nixos/         # system-level, NixOS only
  darwin/        # system-level, nix-darwin only
  home/
    common/      # Home Manager, any OS
    linux/       # Home Manager, Linux only
    darwin/      # Home Manager, macOS only
```

`lib/` imports only the directories that apply to a host's platform, so
Linux-only options simply do not exist on a Mac (typos fail loudly).
Profiles mirror the split (`profiles/{nixos,darwin,home}`).

Rule of thumb: put a module in the *most general* directory where it works.
If one small part is platform-specific, guard it with
`lib.mkIf pkgs.stdenv.hostPlatform.isLinux` rather than splitting the module.

## Consequences

- Clear answer to "where does this go?".
- Host files for a platform cannot accidentally reference options from
  another platform.
