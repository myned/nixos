{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri.misc;
  hm = config.home-manager.users.${config.custom.username};

  _1password = getExe config.programs._1password-gui.package;
  audio = config.home-manager.users.${config.custom.username}.home.file.".local/bin/audio".source;
  bash = "${pkgs.bash}/bin/bash";
  chromium = getExe hm.programs.chromium.package;
  loupe = "${pkgs.loupe}/bin/loupe";
  nautilus = "${pkgs.nautilus}/bin/nautilus";
  niri = "${config.programs.niri.package}/bin/niri";
  sway-audio-idle-inhibit = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
  wallpaper = "${config.home-manager.users.${config.custom.username}.home.file.".local/bin/wallpaper".source}";
in {
  options.custom.desktops.niri.misc = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://github.com/YaLTeR/niri/wiki/Configuration:-Miscellaneous
      programs.niri.settings = {
        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsclipboarddisable-primary
        clipboard.disable-primary = true;

        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingscursorhide-after-inactive-ms
        cursor = with config.stylix.cursor; {
          inherit size;
          theme = name;

          #// hide-after-inactive-ms = 1000 * 15; # Milliseconds
          hide-when-typing = true;
        };

        # HACK: Inherit home-manager environment variables in lieu of upstream fix
        # https://github.com/nix-community/home-manager/issues/2659
        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsenvironment
        environment = mapAttrs (name: value: toString value) hm.home.sessionVariables;

        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingshotkey-overlayskip-at-startup
        hotkey-overlay.skip-at-startup = true;

        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsprefer-no-csd
        prefer-no-csd = true;

        #!! Not executed in a shell
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Key-Bindings#spawn
        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsspawn-at-startup
        spawn-at-startup = [
          {command = [audio "--init"];} # Enforce audio profile state
          {command = [config.custom.menus.clipboard.clear-silent];} # Clear clipboard history
          {command = [_1password "--silent"];}
        ];

        # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsswitch-eventslid-close
        switch-events = mkIf (config.custom.profile == "laptop") {
          # Turn lid display off while inhibiting suspend
          lid-close.action.spawn = [niri "msg" "output" "eDP-1" "off"];
          lid-open.action.spawn = [niri "msg" "output" "eDP-1" "on"];
        };
      };
    };
  };
}
