{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.dms.greeter;
  hm = config.home-manager.users.${config.custom.username};
in {
  # https://danklinux.com/docs/dankgreeter/nixos-flake
  imports = [inputs.dms.nixosModules.greeter];

  options.custom.desktops.dms.greeter = {
    enable = mkEnableOption "greeter";
  };

  config = mkIf cfg.enable {
    # https://danklinux.com/docs/dankgreeter/
    programs.dank-material-shell.greeter = {
      enable = true;
      package = hm.programs.dank-material-shell.package;
      quickshell.package = hm.programs.dank-material-shell.quickshell.package;
      compositor.name = config.custom.desktop;
    };
  };
}
