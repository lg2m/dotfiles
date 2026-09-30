# Module conventions

Rules for writing and placing code. Follow these unless an ADR says otherwise.

## Where does it go?

```
Is it a fact about a machine other machines need?    → inventory.nix
Is it true for exactly one machine?                  → hosts/<name>/
Is it about who the user is (name, email, groups)?   → users/<name>/
Is it an opinion shared by a *class* of machines?    → profiles/
Is it a reusable capability with knobs?              → modules/
Is it a package we build or pin?                     → pkgs/by-name/<name>/package.nix
```

For `modules/`, choose the **most general** directory where it works
(ADR 0003):

| Runs in | Works on | Directory |
|---------|----------|-----------|
| system | NixOS + darwin | `modules/common/` |
| system | NixOS | `modules/nixos/` |
| system | darwin | `modules/darwin/` |
| Home Manager | anywhere | `modules/home/common/` |
| Home Manager | Linux | `modules/home/linux/` |
| Home Manager | macOS | `modules/home/darwin/` |

If a mostly-portable module has one platform-specific piece, keep it in
`common` and guard that piece:

```nix
home.packages = [ pkgs.ouch ] ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.wl-clipboard-rs ];
```

## Module shape

```nix
# One-line summary of what this does.
{ lib, config, pkgs, ... }:
let
  cfg = config.my.<name>;
in
{
  options.my.<name> = {
    enable = lib.mkEnableOption "<what it enables>";
    # further knobs with types, defaults and descriptions
  };

  config = lib.mkIf cfg.enable {
    # ...
  };
}
```

Rules:

- **Namespace:** `my.*` only (ADR 0013). Nest by area: `my.ai.opencode`, `my.vcs.git`.
- **Inert by default:** nothing outside `mkIf cfg.enable`. Exceptions are
  identity/data-only modules like `my.identity` and `my.secrets`, which
  declare options and never emit config on their own.
- **No hidden enables:** a module must not set another module's `enable`.
  That's what profiles are for.
- **No hardcoded user:** use `config.my.core.username` (system) or
  `config.home.username` / `config.my.identity` (HM).
- **No host names in modules:** if behavior differs per host, add an option
  and set it in `hosts/<name>/`.
- **Layout:** `modules/<area>/<name>/default.nix` when it has assets
  (configs, themes), otherwise `modules/<area>/<name>.nix`. Names starting
  with `_` are ignored by `importTree`.
- **Secrets:** never read secret values at eval time. Take a *path*
  (`config.sops.secrets.<x>.path`) and pass it to the service.

## Profiles

- Plain modules (no `enable` option), **imported** by hosts.
- Every scalar value uses `lib.mkDefault` (ADR 0005). Lists and attrsets
  (e.g. `home.packages`) merge.
- A profile may import other profiles (`workstation` imports `base`).
- Desktop profiles come in pairs: `profiles/desktop/<de>/{nixos,home}.nix`
  (ADR 0006).

## Hosts

- `hosts/<name>/default.nix` (system) and `hosts/<name>/home.nix` (HM).
- Only explicit `imports`, no `readDir` (ADR 0004).
- Split big hosts by concern: `hardware.nix`, `storage.nix`,
  `networking.nix`, `<service>.nix`.
- `lib.mkForce` in a host is a smell; fix the profile instead.

## Packages

- `pkgs/by-name/<name>/package.nix` is a normal `callPackage` function and
  becomes `pkgs.<name>` everywhere.
- To pin/patch a nixpkgs package, use the same name and take it as an
  argument: `{ codex, ... }: codex.overrideAttrs ...`. The overlay passes the
  nixpkgs version so this doesn't recurse.
- `nix build .#<name>` builds it; `nix flake check` evaluates it.

## Style

- `nix fmt` (nixfmt, deadnix, statix, shfmt, shellcheck) must be clean;
  `just check` enforces it.
- Comment the *why*, not the *what*. Link issues/ADRs for non-obvious choices.
- Refactors are zero-diff (`just drvs` before/after); behavioral changes say
  what changed in the commit message (ADR 0012).
