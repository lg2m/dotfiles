# dotfiles task runner. `just` lists recipes; docs/runbook/README.md explains them.
#
# Most recipes work on the *current* machine (hostname). Pass a host name to
# target another one, e.g. `just build mimir`, `just deploy mimir`.

set shell := ["bash", "-euo", "pipefail", "-c"]
set positional-arguments := false

host := `hostname -s`
os := os()
nom := if `command -v nom >/dev/null 2>&1 && echo y || echo n` == "y" { "|& nom" } else { "" }

# List recipes
default:
    @just --list --unsorted

####################
# Apply
####################

# Build and activate this machine's config (NixOS, darwin or standalone HM)
[group('apply')]
switch *args:
    #!/usr/bin/env bash
    set -euo pipefail
    case "$(just _kind {{ host }})" in
      nixos)  nh os switch . -H {{ host }} {{ args }} ;;
      darwin) nh darwin switch . -H {{ host }} {{ args }} ;;
      home)   nh home switch . -c "$(just _user {{ host }})@{{ host }}" {{ args }} ;;
    esac

# Activate without making it the boot default (NixOS; a reboot reverts)
[group('apply')]
test *args:
    nh os test . -H {{ host }} {{ args }}

# Make it the boot default without activating now (NixOS)
[group('apply')]
boot *args:
    nh os boot . -H {{ host }} {{ args }}

# Roll back to the previous generation
[group('apply')]
rollback:
    #!/usr/bin/env bash
    set -euo pipefail
    case "$(just _kind {{ host }})" in
      nixos)  sudo nixos-rebuild switch --rollback ;;
      darwin) sudo darwin-rebuild switch --rollback ;;
      home)   home-manager generations | sed -n 2p | awk '{print $NF}' | xargs -I{} {}/activate ;;
    esac

####################
# Remote
####################

# Build locally, activate on a remote NixOS host (target from inventory.nix)
[group('remote')]
deploy target *args:
    nixos-rebuild switch --flake .#{{ target }} --target-host "$(just _deploy {{ target }})" --sudo --ask-sudo-password {{ args }}

# Like deploy, but `test` (no boot entry; reboot recovers from a bad deploy)
[group('remote')]
deploy-test target *args:
    nixos-rebuild test --flake .#{{ target }} --target-host "$(just _deploy {{ target }})" --sudo --ask-sudo-password {{ args }}

####################
# Inspect
####################

# Build a host's config without activating (default: this machine)
[group('inspect')]
build target=host:
    nix build "$(just _attr {{ target }})" --no-link --print-out-paths {{ nom }}

# Show package/closure changes vs what is running (this machine) or vs HEAD
[group('inspect')]
diff target=host:
    #!/usr/bin/env bash
    set -euo pipefail
    new=$(nix build "$(just _attr {{ target }})" --no-link --print-out-paths)
    if [ "{{ target }}" = "{{ host }}" ]; then
      case "$(just _kind {{ target }})" in
        nixos|darwin) old=/run/current-system ;;
        home) old=$(readlink -f ~/.local/state/nix/profiles/home-manager) ;;
      esac
    else
      old=$(nix build "git+file://$PWD?ref=HEAD#$(just _attr {{ target }} | cut -d'#' -f2)" --no-link --print-out-paths)
    fi
    nvd diff "$old" "$new"

# Print every host's derivation path (for zero-diff refactors, ADR 0012)
[group('inspect')]
drvs:
    #!/usr/bin/env bash
    set -euo pipefail
    for h in $(just hosts); do
      printf '%s %s\n' "$h" "$(nix eval --raw "$(just _attr "$h").drvPath")"
    done

# List hosts from inventory.nix
[group('inspect')]
hosts:
    @nix eval --raw --impure --expr 'builtins.concatStringsSep "\n" (builtins.attrNames (import ./inventory.nix))'; echo

# Open a REPL with the flake loaded
[group('inspect')]
repl:
    nix repl .

####################
# Quality
####################

# Evaluate all hosts for this system + formatting (what CI runs)
[group('quality')]
check *args:
    nix flake check {{ args }}

# Format everything
[group('quality')]
fmt:
    nix fmt

####################
# Maintenance
####################

# Update all flake inputs, or just the named ones
[group('maintenance')]
update *inputs:
    nix flake update {{ inputs }}

# Remove old generations and garbage-collect
[group('maintenance')]
gc keep="5" since="7d":
    nh clean all --keep {{ keep }} --keep-since {{ since }}

####################
# Secrets
####################

# Edit (or create) a secrets file, e.g. secrets/hosts/thor.yaml
[group('secrets')]
secrets-edit file:
    sops {{ file }}

# Re-encrypt every secrets file after changing recipients in .sops.yaml
[group('secrets')]
secrets-updatekeys:
    find secrets -name '*.yaml' -print0 | xargs -0 -r -n1 sops updatekeys --yes

# Print a host's age recipient from its SSH host key (local or over SSH)
[group('secrets')]
host-age target=host:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{ target }}" = "{{ host }}" ]; then
      ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
    else
      ssh-keyscan -t ed25519 {{ target }} 2>/dev/null | ssh-to-age
    fi

# Print the admin/user age recipient from ~/.config/sops/age/keys.txt
[group('secrets')]
my-age:
    age-keygen -y ~/.config/sops/age/keys.txt

####################
# Internal
####################

[private]
_kind target:
    @nix eval --raw --impure --expr '(import ./inventory.nix).{{ target }}.kind'

[private]
_user target:
    @nix eval --raw --impure --expr '(import ./inventory.nix).{{ target }}.user'

[private]
_deploy target:
    @nix eval --raw --impure --expr '(import ./inventory.nix).{{ target }}.deploy.target or (throw "{{ target }} has no deploy.target in inventory.nix")'

# Flake attribute of a host's top-level build
[private]
_attr target:
    #!/usr/bin/env bash
    set -euo pipefail
    case "$(just _kind {{ target }})" in
      nixos)  echo ".#nixosConfigurations.{{ target }}.config.system.build.toplevel" ;;
      darwin) echo ".#darwinConfigurations.{{ target }}.config.system.build.toplevel" ;;
      home)   echo ".#homeConfigurations.\"$(just _user {{ target }})@{{ target }}\".activationPackage" ;;
    esac
