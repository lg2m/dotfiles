# Machine inventory: *facts* about each machine (see docs/adr/0007).
#
# Pure data only: no pkgs, no config. Consumed by lib/ to build
# nixosConfigurations / darwinConfigurations / homeConfigurations, and by
# modules (via the `host` / `inventory` specialArgs) for cross-host data.
#
# Fields:
#   kind      "nixos" | "darwin" | "home" (standalone Home Manager)
#   system    nix system double
#   user      primary user (must exist under users/)
#   hostKey   SSH *host* public key (/etc/ssh/ssh_host_ed25519_key.pub);
#             its age form is a sops recipient. null for kind = "home".
#   userKey   the user's SSH public key *on this machine*; other hosts that
#             list this machine in `sshFrom` authorize it.
#   sshFrom   machines allowed to SSH *into* this one as `user`.
#   sshAlias  extra ~/.ssh/config settings other machines use to reach it
#             (null = not an SSH target).
#   deploy    { target = "user@host"; } for `just deploy <name>`, or null.
{
  thor = {
    kind = "nixos";
    system = "x86_64-linux";
    user = "zmeyer";
    hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBltUUn9p+KT3fzXkL5u5CgadulMPJvqtFNjP4VhEpKp";
    userKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILd4BrvWfGcQCwmdhvUkJ7P81ftqoGQ6vJsUs6+6IFPm thor";
    sshFrom = [ "syn0201" ];
    deploy = null;
  };

  mimir = {
    kind = "nixos";
    system = "x86_64-linux";
    user = "zmeyer";
    # TODO(sops): fill from `ssh-keyscan -t ed25519 mimir` (mimir unreachable when this was written)
    hostKey = null;
    userKey = null;
    sshFrom = [
      "thor"
      "syn0201"
    ];
    deploy.target = "zmeyer@mimir";
  };

  syn0201 = {
    kind = "home";
    system = "x86_64-linux";
    user = "zmeyer";
    hostKey = null;
    userKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFp93ayCGKzh1aqE7pissZySnkGClHK023SfUoYIHnQ3 syn0201";
    sshFrom = [ ];
    deploy = null;
  };
}
