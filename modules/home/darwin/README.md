Home Manager modules that only make sense on macOS. Empty for now; see
docs/design/module-conventions.md for when to add one here vs guarding a
common module with `pkgs.stdenv.hostPlatform.isDarwin`.
