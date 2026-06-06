{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.dms.plugins;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.desktops.dms.plugins = {
    enable = mkEnableOption "plugins";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/AvengeMedia/dms-plugin-registry
        imports = [inputs.dms-plugin-registry.modules.default];

        # https://danklinux.com/plugins
        programs.dank-material-shell.plugins = {
        };
      }
    ];
  };
}
