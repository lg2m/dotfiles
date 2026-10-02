# Desktop environments

Desktops are profile pairs (ADR 0006). A host imports zero or one pair.

| Desktop | System half | HM half | Used by |
|---------|-------------|---------|---------|
| Hyprland | `profiles/desktop/hyprland/nixos.nix` | `profiles/desktop/hyprland/home.nix` | thor |
| Plasma 6 | `profiles/desktop/plasma/nixos.nix` | `profiles/desktop/plasma/home.nix` | mimir |
| none | – | – | headless / servers |

Switching a host's desktop means changing two imports:

```nix
# hosts/<name>/default.nix
../../profiles/desktop/hyprland/nixos.nix

# hosts/<name>/home.nix
../../profiles/desktop/hyprland/home.nix
```

## Hyprland

### Module boundaries

| What | Where |
|------|-------|
| Reusable system foundations (portal, xwayland) | `modules/nixos/hyprland/` (`my.hyprland.enable`) |
| Reusable session config (binds, cursor, env) | `modules/home/linux/hyprland/base.nix` |
| Session components (eww, mako, hypridle, hyprlock, yofi, awww, screenshot, screencast, clipboard, thunar) | `modules/home/linux/hyprland/<component>/` (`my.hyprland.<component>.enable`) |
| "A Hyprland desktop" (SDDM, default session, which components) | `profiles/desktop/hyprland/` |
| Monitor layout, startup apps, autologin | `hosts/<name>/` |

If a setting would make sense on another Hyprland machine, it belongs in the
module or profile, not the host.

### Per-host overrides (HM)

```nix
# hosts/thor/home.nix
my.hyprland = {
  monitors = [ ",5120x1440@239.76,auto,1" ];
  startup = [ "goxlr-daemon" ];
  # extraBinds, workspaceRules, apps.{terminal,browser,...}
};
```

### Bar (eww)

`modules/home/linux/hyprland/eww/`. It runs as the `eww` systemd user service,
starts with `graphical-session.target` and restarts on crash. `home-manager
switch` restarts it automatically when `eww.yuck`/`eww.scss` change.

| Action | How |
|--------|-----|
| Restart the bar | `Super+Shift+B` or `systemctl --user restart eww` |
| Reload config in place | `eww reload` |
| Debug | `eww logs`, `eww state`, `journalctl --user -u eww` |
| Toggle do-not-disturb | `Super+N` or the bell icon (mako `do-not-disturb` mode) |

Layout: workspaces (only occupied plus the active one; scroll to cycle) · git
`repo:branch` of the focused window | window title | media · CPU/mem/net ·
tray · rec/DND · volume (scroll / click to mute / right-click for the mixer) · clock
(click for the calendar) · power menu.

Data comes from event-driven listeners in `eww/scripts/`: the Hyprland socket2,
`pactl subscribe`, `playerctl --follow`, and a 2s stats sampler. There's no
per-second `hyprctl` polling. Each script is a `writeShellApplication` with
its own runtime deps; Nix substitutes their paths into `eww.yuck` (`@hypr@` etc.).
To iterate without switching, run a second instance:
`eww -c /tmp/ewwt daemon && eww -c /tmp/ewwt open bar-main` with a copy of the
built yuck (`nix build .#nixosConfigurations.thor.config.home-manager.users.zmeyer.xdg.configFile."eww/eww.yuck".source`).

### Validation

```sh
nix eval .#nixosConfigurations.thor.config.programs.hyprland.enable
nix eval .#nixosConfigurations.thor.config.home-manager.users.zmeyer.wayland.windowManager.hyprland.enable
just test          # activate without a boot entry
just switch
```

### Smoke test checklist

- SDDM starts directly into the Hyprland session (autologin on thor).
- Monitor layout and workspaces are correct.
- Launcher (yofi), notifications (mako), idle/lock (hypridle/hyprlock),
  wallpaper (awww), screenshots.
- Clipboard, browser/Electron apps under Wayland, 1Password prompts, Steam.

## Plasma

Plasma manages its own session config, so the HM half is empty. Printing
(CUPS) comes with the Plasma profile.
