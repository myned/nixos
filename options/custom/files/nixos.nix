{ config, lib, ... }:

with lib;

let
  cfg = config.custom.files.nixos;
in
{
  options.custom.files.nixos.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
    # Create NixOS configuration directory and set permissions
    systemd.tmpfiles.rules = [
      "d /etc/nixos 0755 myned root"
      "Z /etc/nixos - myned root" # Recursively set owner
    ];
  };
}
