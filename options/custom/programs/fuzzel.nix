{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.fuzzel;
in {
  options.custom.programs.fuzzel.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://codeberg.org/dnkl/fuzzel
    programs.fuzzel = {
      enable = true;

      settings = {
        main = {
          font = "${config.gtk.font.name}:size=12";
          icon-theme = config.gtk.iconTheme.name;
          horizontal-pad = 20;
          inner-pad = 12;
          lines = 5;
          line-height = 25;
          vertical-pad = 12;
          layer = "overlay";
        };

        colors = {
          background = "073642ff";
          selection = "002b36ff";
          selection-text = "eee8d5ff";
          text = "93a1a1ff";
        };

        border = {
          radius = 20;
          width = 2;
        };
      };
    };
  };
}
