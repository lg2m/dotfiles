# Persistent Waypoint runner on Mimir

Mimir registers two persistent runners with the Waypoint-Interactive organization.
The fast runner is mimir-waypoint, unit github-runner-waypoint-mimir.service, label
waypoint-trusted (four CPUs/8 GiB). The full runner is mimir-waypoint-full, unit
github-runner-waypoint-mimir-full.service, label waypoint-full (four CPUs/10 GiB).
Both remain online and display Idle between jobs. The existing veyr-lang runner services and tokens are unchanged.

## Token and repository access

Use a fine-grained token whose resource owner is Waypoint-Interactive and whose
organization Self-hosted runners permission is Read and write. Keep its value only
in /etc/idle-ci/github-token, root-owned mode0600. No token contents, home WAN
addresses or provider credentials are committed to Git or evaluated into Nix.
A repository-only Administration token cannot register an organization runner.

Alternatively, the organization New self-hosted runner page supplies a registration
token. The NixOS module accepts either type automatically, but registration tokens
expire after one hour and must be refreshed if later reconfiguration needs one.
An unexpired fine-grained token is simpler for future unattended re-registration.

In organization Settings → Actions → Runner groups, limit this runner's group to
selected trusted repositories, initially Idle. Confirm the actual policy before
activation; labels are selection hints, not authorization. Restrict public/fork PR
execution. This host runner has Docker access, which is effectively host-root
access. It is for reviewed, trusted workloads only; a separate Linux account and
systemd hardening do not make it a sandbox for malicious code. No deployment or
production credentials are supplied.

Each service handles one job at a time. Their 18 GiB combined hard limit fits inside
the existing fleet's 20 GiB cap; monitor concurrent veyr-lang usage as well. Separate
services prevent a long full validation job from blocking the fast PR queue.
Registration state persists under /var/lib/github-runner/waypoint-mimir; the separate
workspace is /var/lib/waypoint-runner-work, created by systemd StateDirectory before
startup namespaces are prepared. Registration-state cleanup cannot delete it;
workspaces are not fresh VMs. The module cleans its work directory on service start.

## Build and activate

On Mimir, from the dotfiles repository root:

```sh
nix build .#nixosConfigurations.mimir.config.system.build.toplevel --out-link ~/.local/share/idle-ci/mimir-system-persistent
```

Activate the already-built system without a root-side private Git fetch or a boot
change. This also starts the configured runner:

```sh
sudo ~/.local/share/idle-ci/mimir-system-persistent/bin/switch-to-configuration test
systemctl status github-runner-waypoint-mimir.service
journalctl -u github-runner-waypoint-mimir.service -n 30 --no-pager
```

After checking host connectivity and the runner's Idle status in GitHub, persist
the same system as the boot default:

```sh
sudo nix-env --profile /nix/var/nix/profiles/system --set ~/.local/share/idle-ci/mimir-system-persistent
sudo ~/.local/share/idle-ci/mimir-system-persistent/bin/switch-to-configuration switch
```

Before persistence, rebooting returns to the previous boot configuration. Once
persisted, use sudo nixos-rebuild switch --rollback to recover a prior generation.
This setup needs no idle-ci.service, request.json, manual job admission, extra
control repository, application-source flake input, local CIDR file or nftables
backend change. The earlier disposable-controller proposal is superseded.

## Jobs and maintenance

Fast workflows select [self-hosted, Linux, X64, waypoint-trusted]; full qualification
selects [self-hosted, Linux, X64, waypoint-full]. Registering a runner
does not itself change a workflow that still selects ubuntu-24.04. Keep that wiring
and its actual verification results in the application repository. A running service
alone does not prove that checkout, native Node actions, Docker or full CI passes.

Keep the token unexpired and the pinned github-runner package current; GitHub rejects
old runner versions. For expired credentials, update the protected token file then
restart the service. If GitHub deleted the runner registration, inspect its journal
before re-registering; do not delete the other organization's runner state. The
module disables self-updates, so updates belong in NixOS rebuilds.

Useful pages:

- https://github.com/organizations/Waypoint-Interactive/settings/actions/runners
- https://github.com/settings/personal-access-tokens
- https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners

## Workspace startup regression

The workspace must not be nested inside registration state. The upstream module
clears that state during reconfiguration, and systemd needs the workspace present
before setting up mount namespaces. An additional StateDirectory creates and owns
the separate workspace before any startup command runs.

The x86_64-linux flake check waypoint-runner-workspace boots two VMs: the old layout
reproduces 226/NAMESPACE; the corrected layout starts and restarts after registration
state cleanup. It uses the real NixOS module and systemd with a stub Runner.Listener;
no real token or GitHub API request is involved. Run it separately with:

```sh
nix-build --no-out-link tests/waypoint-runner-workspace.nix
```

Live organization registration remains a separate acceptance check.

The runner uses the shared /tmp and /var/tmp for Docker bind-path consistency.
ProtectSystem remains strict, with only the workspace/state and these temporary
paths writable. Disabling PrivateTmp without explicitly allowing those paths makes
nix develop fail with a read-only-filesystem error. The VM regression includes
that broken configuration and verifies temporary-file creation in the fixed service.

Fast PR checks should report stage timings and target 1–3 minutes warm, with a
five-minute execution budget. Full qualification is requested at merge readiness
using the full-ci PR label (or manual dispatch after that workflow reaches main).
Keep the label on during finalization so new commits get fresh full evidence. Both
verify and verify-full must succeed on the current head before merge. A skipped full
job does not qualify. See the application CI runbook for the authoritative policy.
