{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings;
in {
  options.custom.settings = {
    enable = mkEnableOption "settings";
  };

  config = mkIf cfg.enable {
    custom.settings = mkMerge [
      (mkIf config.custom.default {
        boot.enable = mkDefault true;
        environment.enable = mkDefault true;
        hardware.enable = mkDefault true;
        networking.enable = mkDefault true;
        packages.enable = mkDefault true;
        storage.enable = mkDefault true;
        users.enable = mkDefault true;
      })

      (mkIf config.custom.minimal {
        fonts.enable = mkDefault true;
        nixgl.enable = mkDefault true;
        stylix.enable = mkDefault true;
        xdg.enable = mkDefault true;
      })

      (mkIf config.custom.full {
        waydroid.enable = mkDefault true;
      })
    ];
  };
}
