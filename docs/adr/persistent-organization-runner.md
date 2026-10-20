# Persistent organization runner on Mimir

- Status: accepted configuration; activation and registration pending
- Date: 2026-10-20

## Context

The owner wants an always-online runner for Waypoint-Interactive that displays Idle
between jobs and can serve several trusted repositories. Existing Mimir runners
belong to veyr-lang and must keep their assignments and token files.
The owner explicitly selected persistent organization registration over the proposed
operator-started disposable VM design.

## Decision

Use the standard NixOS services.github-runners module for one persistent registration
named mimir-waypoint, scoped to https://github.com/Waypoint-Interactive. Its dedicated
system user has Docker access for CI database/container tests. Limit the GitHub runner
group to selected trusted repositories; labels are not an access-control boundary.
Use four CPUs/12 GiB RAM within the existing fleet's aggregate resource slice.

Read the organization-capable token from /etc/idle-ci/github-token at runtime only.
No token values or host network addresses belong in Git. Keep the ordinary firewall
backend and pure dotfiles evaluation; no Idle source input or local network file is
required. NixOS owns runner updates rather than the runner's self-updater.

## Consequences

The runner is visible as Idle between jobs, Busy during jobs and Offline when its
service or host is stopped. It automatically starts at boot after persistent NixOS
activation. Existing CI workflows must explicitly select its labels before they run
here. Org credentials, repository access and actual job execution are separate gates.

Persistent workspaces and host Docker access mean all admitted workflow writers are
trusted with this machine. This is not an isolation boundary for untrusted PR code;
use separate isolated runners for those jobs. No production deployment credentials
are supplied. See the [runbook](../runbook/waypoint-runner.md).
