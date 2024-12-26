{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.stylix;
in {
  options.custom.settings.stylix = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://stylix.danth.me/
    stylix = {
      enable = true;
    };
  };
}
