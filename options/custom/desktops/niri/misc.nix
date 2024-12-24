{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  niri = "${config.programs.niri.package}/bin/niri";
  sway-audio-idle-inhibit = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";

  cfg = config.custom.desktops.niri.misc;
in {
  options.custom.desktops.niri.misc = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      programs.niri.settings = {
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Miscellaneous

        spawn-at-startup = [
          {command = [sway-audio-idle-inhibit];} # Inhibit while audio is playing
        ];

        # HACK: Inherit home-manager environment variables in lieu of upstream fix
        # https://github.com/nix-community/home-manager/issues/2659
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Miscellaneous#environment
        environment = mapAttrs (name: value: builtins.toString value) config.home-manager.users.${config.custom.username}.home.sessionVariables;

        cursor = {
          hide-after-inactive-ms = 1000 * 15; # Milliseconds
          hide-when-typing = true;
        };

        hotkey-overlay.skip-at-startup = true;
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
