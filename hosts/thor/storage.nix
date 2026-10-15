# /data: LUKS-encrypted secondary NVMe drive, unlocked at boot with a keyfile
# on the root disk. Initialize with scripts/setup-thor-storage.
# The 500 GB Samsung (formerly /scratch) is a Windows disk and is not managed here.
{ config, ... }:
let
  user = config.my.core.username;
in
{
  environment.etc."crypttab".text = ''
    data UUID=c6dd0f62-22ce-48b7-b048-9e22be9803a0 /root/.keys/data.key luks
  '';

  fileSystems."/data" = {
    device = "/dev/mapper/data";
    fsType = "ext4";
  };

  systemd.tmpfiles.rules = [
    "d /data 2775 ${user} users -"
  ];
}
