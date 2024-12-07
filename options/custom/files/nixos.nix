{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.files.nixos;
in {
  options.custom.files.nixos.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html
    # Create NixOS configuration directory and set permissions
    systemd.tmpfiles.settings."10-nixos" = {
      "/etc/nixos" = {
        d = {
          mode = "0755";
          user = config.custom.username;
          group = "root";
        };

        #!! Recursive
        Z = {
          user = config.custom.username;
          group = "root";
        };
      };
    };
  };
}
