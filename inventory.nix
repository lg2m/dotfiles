# Machine inventory: *facts* about each machine (see docs/adr/0007).
#
# Pure data only: no pkgs, no config. Consumed by lib/ to build
# nixosConfigurations / darwinConfigurations / homeConfigurations, and by
# modules (via the `host` / `inventory` specialArgs) for cross-host data.
#
# Fields:
#   kind        "nixos" | "darwin" | "home" (standalone Home Manager)
#   system      nix system double
#   user        primary user (must exist under users/)
#   hostKey     SSH *host* public key (/etc/ssh/ssh_host_ed25519_key.pub).
#               Its age form is this machine's sops recipient (.sops.yaml).
#               null for kind = "home" or when not yet known.
#   userKey     public half of the key this machine's user presents to
#               *other* machines. Authorized on every host listing this
#               machine in `sshFrom`.
#   userKeyFile file name (in ~/.ssh) of that key's private half.
#   sshFrom     machines allowed to SSH *into* this one as `user`. Also makes
#               this machine appear in their ~/.ssh/config.
#   deploy      { target = "user@host"; } for `just deploy <name>`, or null.
{
  thor = {
    kind = "nixos";
    system = "x86_64-linux";
    user = "zmeyer";
    hostKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBltUUn9p+KT3fzXkL5u5CgadulMPJvqtFNjP4VhEpKp";
    userKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILd4BrvWfGcQCwmdhvUkJ7P81ftqoGQ6vJsUs6+6IFPm thor";
    userKeyFile = "mimir_ed25519";
    sshFrom = [ "syn0201" ];
    deploy = null;
  };

  mimir = {
    kind = "nixos";
    system = "x86_64-linux";
    user = "zmeyer";
    # TODO: `ssh-keyscan -t ed25519 mimir` (was unreachable when this was written)
    hostKey = null;
    userKey = null;
    userKeyFile = "id_ed25519";
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
    userKeyFile = "syn0201_ed25519";
    sshFrom = [ ];
    deploy = null;
  };
}
