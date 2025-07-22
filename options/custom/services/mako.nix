{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.mako;
in {
  options.custom.services.mako = {
    enable = mkEnableOption "mako";
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://github.com/emersion/mako
      # FIXME: Cairo subpixel rendering; WL_OUTPUT_SUBPIXEL_NONE?
      # https://github.com/emersion/mako/issues/258
      services.mako = {
        enable = true;
        borderRadius = 12;
        borderSize = 2;
        defaultTimeout = 5 * 1000; # 5 seconds
        width = 750;
        anchor = "top-center";
        backgroundColor = "#073642";
        borderColor = "#002b36";
        font = "${config.stylix.fonts.monospace.name} 12";
        layer = "overlay";
        margin = "20";
        padding = "10";
      };

      # https://nix-community.github.io/stylix/options/modules/mako.html
      stylix.targets.mako.enable = false;
    };
  };
}
