{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri.misc;
  hm = config.home-manager.users.${config.custom.username};

  audio = config.home-manager.users.${config.custom.username}.home.file.".local/bin/audio".source;
  niri = "${config.programs.niri.package}/bin/niri";
  rm = "${pkgs.coreutils}/bin/rm";
  sway-audio-idle-inhibit = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
  wallpaper = "${config.home-manager.users.${config.custom.username}.home.file.".local/bin/wallpaper".source}";
in {
  options.custom.desktops.niri.misc = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Miscellaneous
        programs.niri.settings = {
          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingscursorhide-after-inactive-ms
          cursor = with hm.gtk.cursorTheme; {
            # Inherit home-manager GTK settings
            inherit size;
            theme = name;

            # BUG: Heavily increases CPU usage with cursor movement
            # https://github.com/YaLTeR/niri/issues/1037
            #// hide-after-inactive-ms = 1000 * 15; # Milliseconds
            #// hide-when-typing = true;
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
          spawn-at-startup = let
            home = hm.home.homeDirectory;
          in
            [
              {command = [audio "--init"];} # Enforce audio profile state
              {command = [rm "${home}/.cache/walker/clipboard.gob"];} # Clear clipboard history
              {command = [sway-audio-idle-inhibit];} # Inhibit while audio is playing
            ]
            ++ optionals config.custom.wallpaper [
              {command = [wallpaper];}
            ];

          # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsswitch-eventslid-close
          switch-events = {
            # Turn display off while inhibiting suspend
            lid-close.action.spawn = [niri "msg" "action" "power-off-monitors"];
            lid-open.action.spawn = [niri "msg" "action" "power-on-monitors"];
          };
        };
      }
    ];
  };
}
