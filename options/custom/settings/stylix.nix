{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.stylix;
in {
  options.custom.settings.stylix = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # TODO: Use stylix for theming
    # https://stylix.danth.me/
    stylix = {
      # BUG: Assertion failure, set to true when merged
      # https://github.com/danth/stylix/pull/912
      enable = false;

      base16Scheme = "${pkgs.base16-schemes}/share/themes/solarized-dark.yaml";
    };
  };
}
