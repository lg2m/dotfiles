# Progress — Plan 0001 (re-architecture)

Branch: `rearch`

## Baseline (main @ c59f5e0)

```
thor    /nix/store/mbd062rxb86cvc9vm3ng7s7ph6shb9zv-nixos-system-thor-26.11.20260922.6774f7b.drv
mimir   /nix/store/s61rw11kln0n9p3p56ayy1lx53w1wryn-nixos-system-mimir-26.11.20260922.6774f7b.drv
syn0201 /nix/store/fdaa7m0j1ah4kcfapbkirpq0yal9w4py-home-manager-generation.drv
```

## Phases

- [x] 0. Prep — staged work committed on main, branch created, `.tmp_rsa_key*` deleted, baseline recorded
- [x] 1. Docs skeleton + ADRs 0001–0013
- [ ] 2. Flake plumbing (zero-diff)
- [ ] 3. lib + inventory (zero-diff)
- [ ] 4. Directory restructure (zero-diff)
- [ ] 5. Profiles (reviewed diff)
- [ ] 6. Cleanup (`my.*`, hardcoded user, channels, platform guards)
- [ ] 7. Inventory-driven SSH
- [ ] 8. sops-nix
- [ ] 9. Remote deploy + nh
- [ ] 10. Darwin scaffolding
- [ ] 11. Finalize docs

## Log
