# Hyprland Notes

## Module Boundaries

- Put reusable desktop foundations in `modules/system/shared/hyprland` and `modules/home/shared/hyprland`.
- Keep `modules/system/thor/hyprland` limited to login-path and host-only system behavior.
- Keep `modules/home/thor/hyprland` limited to `thor` monitor layout, workspace placement, and other machine-specific session overrides.
- If a setting would make sense on another Hyprland machine, move it back to `shared`.

## Where To Add Overrides

- Add shared system behavior in `modules/system/shared/hyprland/default.nix`.
- Add shared Home Manager behavior in `modules/home/shared/hyprland/`.
- Add `thor`-only system overrides in `modules/system/thor/hyprland/default.nix`.
- Add `thor`-only Hyprland session overrides in `modules/home/thor/hyprland/default.nix`.

## Validation Commands

- Evaluate the host config: `nix eval .#nixosConfigurations.thor.config.programs.hyprland.enable`
- Test the full host build: `sudo nixos-rebuild test --flake .#thor`
- Apply the host build: `sudo nixos-rebuild switch --flake .#thor`
- Inspect the Home Manager Hyprland config on `thor`: `nix eval .#nixosConfigurations.thor.config.home-manager.users.zmeyer.wayland.windowManager.hyprland.enable`

## Smoke Test Checklist

- Confirm SDDM starts directly into the Hyprland session.
- Verify monitor layout and workspaces on `thor`.
- Check launcher, notifications, idle/lock flow, wallpaper, and screenshots.
- Check clipboard, browser/Electron apps, 1Password prompts, Steam, gamescope, and gamemode.
