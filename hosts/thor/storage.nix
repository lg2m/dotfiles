# /data and /scratch: LUKS-encrypted secondary NVMe drives, unlocked at boot
# with a keyfile on the root disk. Initialize with scripts/setup-thor-storage.
{ config, ... }:
let
  user = config.my.core.username;
in
{
  environment.etc."crypttab".text = ''
    data UUID=c6dd0f62-22ce-48b7-b048-9e22be9803a0 /root/.keys/data.key luks
    scratch UUID=aae545d4-3821-4a8e-af7d-2bb2c1458dfc /root/.keys/data.key luks
  '';

  fileSystems = {
    "/data" = {
      device = "/dev/mapper/data";
      fsType = "ext4";
    };
    "/scratch" = {
      device = "/dev/mapper/scratch";
      fsType = "ext4";
    };
  };

  systemd.tmpfiles.rules = [
    "d /data 2775 ${user} users -"
    "d /scratch 2775 ${user} users -"
  ];
}
