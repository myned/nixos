{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri.misc;

  audio = config.home-manager.users.${config.custom.username}.home.file.".local/bin/audio".source;
in {
  options.custom.desktops.niri.misc = {
    enable = mkEnableOption "misc";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Miscellaneous
        wayland.windowManager.niri.settings = {
          clipboard.disable-primary = [];
          hotkey-overlay.skip-at-startup = [];
          overview.backdrop-color = "#073642";
          overview.zoom = 0.5;
          prefer-no-csd = [];

          cursor = with config.stylix.cursor; {
            hide-after-inactive-ms = 15 * 1000; # Milliseconds
            hide-when-typing = [];
            xcursor-size = size;
            xcursor-theme = name;
          };

          # HACK: Inherit home-manager environment variables in lieu of upstream fix
          # https://github.com/nix-community/home-manager/issues/2659
          #// environment = mapAttrs (name: value: toString value) hm.home.sessionVariables;

          #!! Not executed in a shell
          # https://github.com/YaLTeR/niri/wiki/Configuration:-Key-Bindings#spawn
          spawn-at-startup = [
            [audio "--init"] # Enforce audio profile state
            [config.custom.menus.clipboard.clear-silent] # Clear clipboard history
          ];
        };
      }
    ];
  };
}
