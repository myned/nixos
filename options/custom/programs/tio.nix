{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.tio;
in {
  options.custom.programs.tio.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # Allow serial device access
    # https://github.com/tio/tio?tab=readme-ov-file#46-known-issues
    users.users.${config.custom.username}.extraGroups = ["dialout"];

    # https://github.com/tio/tio
    #!! Options not available, files written directly
    home-manager.users.${config.custom.username}.xdg.configFile."tio/config".text = ''
      baudrate = 9600
    '';
  };
}
