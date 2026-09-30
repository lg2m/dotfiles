# Architecture Decision Records

Short records of *why* the repo is shaped the way it is. See
[0001](0001-record-architecture-decisions.md) for when to write one and
[template.md](template.md) for the format.

| # | Title | Status |
|---|-------|--------|
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | accepted |
| [0002](0002-layered-modules-and-host-inventory.md) | Layered modules + host inventory | accepted |
| [0003](0003-platform-split.md) | Platform split | accepted |
| [0004](0004-module-contract.md) | Module contract and explicit imports | accepted |
| [0005](0005-profiles-use-mkdefault.md) | Profiles set options with `mkDefault` | accepted |
| [0006](0006-desktop-as-profiles.md) | Desktop environments as profiles | accepted |
| [0007](0007-inventory-facts-vs-host-choices.md) | Inventory holds facts, hosts hold choices | accepted |
| [0008](0008-sops-nix-key-model.md) | Secrets with sops-nix; host SSH keys + admin age key | accepted |
| [0009](0009-per-host-secret-files.md) | Secret files are scoped per host | accepted |
| [0010](0010-remote-deploy.md) | Remote deploy with `--target-host` | accepted |
| [0011](0011-tooling.md) | Tooling: just, nh, treefmt-nix, devShell, flake checks | accepted |
| [0012](0012-zero-diff-refactors.md) | Refactors are verified as zero-diff | accepted |
| [0013](0013-option-namespace-my.md) | Option namespace `my.*` | accepted |
