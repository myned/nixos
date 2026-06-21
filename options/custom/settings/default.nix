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
        boot.enable = true;
        environment.enable = true;
        hardware.enable = true;
        networking.enable = true;
        packages.enable = true;
        storage.enable = true;
        users.enable = true;
      })

      (mkIf config.custom.minimal {
        fonts.enable = true;
        nixgl.enable = true;
        stylix.enable = true;
        xdg.enable = true;
      })

      (mkIf config.custom.full {
        waydroid.enable = true;
      })
    ];
  };
}
