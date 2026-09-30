# Silent boot: no kernel/console spam, no blinking cursor.
{ lib, ... }:
{
  boot = {
    kernelParams = [
      "quiet"
      "splash"
      "vt.global_cursor_default=0"
      "console=/dev/null"
    ];
    consoleLogLevel = lib.mkDefault 3;
    initrd.verbose = lib.mkDefault false;
    # Upstream sets this from consoleLogLevel at mkDefault; override plainly.
    kernel.sysctl."kernel.printk" = "0 0 0 0";
  };
}
