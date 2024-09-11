{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.wireshark;
in
{
  options.custom.programs.wireshark.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://gitlab.com/wireshark/wireshark
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark; # GUI
    };

    users.users.${config.custom.username}.extraGroups = [ "wireshark" ];
  };
}
