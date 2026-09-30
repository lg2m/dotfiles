# TEMPLATE: copy to hosts/<name>/ and follow docs/runbook/add-host-darwin.md.
_: {
  imports = [
    ../../users/zmeyer/darwin.nix
    ../../profiles/darwin/base.nix
  ];

  # Set if Nix was installed with the Determinate installer.
  # my.core.determinateNix = true;

  # Once enrolled in sops (secrets/hosts/<name>.yaml exists):
  # my.secrets.sshKeys = [ "github" ];

  # Read the release notes before changing.
  system.stateVersion = 6;
}
