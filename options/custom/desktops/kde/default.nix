{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.kde;
in {
  options.custom.desktops.kde = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;

    home-manager.sharedModules = [
      {
        # https://nix-community.github.io/stylix/options/modules/kde.html
        stylix.targets.kde.enable = true;
      }
    ];
  };
}
