{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.tio;
in {
  options.custom.programs.tio.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://github.com/tio/tio
    environment.systemPackages = [pkgs.tio];

    # Allow serial device access
    # https://github.com/tio/tio?tab=readme-ov-file#46-known-issues
    users.users.${config.custom.username}.extraGroups = ["dialout"];

    #!! Options not available, files written directly
    home-manager.users.${config.custom.username}.xdg.configFile."tio/config".text = ''
      baudrate = 9600
    '';
  };
}
