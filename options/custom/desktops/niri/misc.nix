{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  _1password = "${config.programs._1password-gui.package}/bin/1password";
  audio = config.home-manager.users.${config.custom.username}.home.file.".local/bin/audio".source;
  niri = "${config.programs.niri.package}/bin/niri";
  rm = "${pkgs.coreutils}/bin/rm";
  sway-audio-idle-inhibit = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
  wallpaper = "${config.home-manager.users.${config.custom.username}.home.file.".local/bin/wallpaper".source}";

  cfg = config.custom.desktops.niri.misc;
in {
  options.custom.desktops.niri.misc = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      programs.niri.settings = {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Miscellaneous

        # https://github.com/YaLTeR/niri/wiki/Configuration:-Miscellaneous#spawn-at-startup
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Key-Bindings#actions
        spawn-at-startup = let
          home = config.home-manager.users.${config.custom.username}.home.homeDirectory;
        in
          [
            {command = [_1password "--silent"];} # Launch password manager in background
            {command = [audio "--init"];} # Enforce audio profile state
            {command = [rm "${home}/.cache/walker/clipboard.gob"];} # Clear clipboard history
            {command = [sway-audio-idle-inhibit];} # Inhibit while audio is playing
          ]
          ++ optionals config.custom.wallpaper [
            {command = [wallpaper];}
          ];

        # HACK: Inherit home-manager environment variables in lieu of upstream fix
        # https://github.com/nix-community/home-manager/issues/2659
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Miscellaneous#environment
        environment =
          mapAttrs (name: value: toString value)
          config.home-manager.users.${config.custom.username}.home.sessionVariables;

        # https://github.com/YaLTeR/niri/wiki/Configuration:-Miscellaneous#cursor
        cursor = with config.home-manager.users.${config.custom.username}.gtk.cursorTheme; {
          # Inherit home-manager GTK settings
          inherit size;
          theme = name;

          hide-after-inactive-ms = 1000 * 15; # Milliseconds
          hide-when-typing = true;
        };

        # https://github.com/YaLTeR/niri/wiki/Configuration:-Miscellaneous#hotkey-overlay
        hotkey-overlay.skip-at-startup = true;

        # https://github.com/YaLTeR/niri/wiki/Configuration:-Miscellaneous#prefer-no-csd
        prefer-no-csd = true;

        # https://github.com/YaLTeR/niri/wiki/Configuration:-Switch-Events
        switch-events = {
          # Turn display off while inhibiting suspend
          lid-close.action.spawn = [niri "msg" "action" "power-off-monitors"];
          lid-open.action.spawn = [niri "msg" "action" "power-on-monitors"];
        };
      };
    };
  };
}
