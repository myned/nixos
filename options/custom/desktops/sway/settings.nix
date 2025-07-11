{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.sway.settings;
in {
  options.custom.desktops.sway.settings.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.sway.config
    # https://github.com/swaywm/sway/blob/master/config.in
    # https://i3wm.org/docs/
    #?? man 5 sway
    wayland.windowManager.sway = {
      config = {
        #!! Module order causes many issues, use extraConfig
        #// assigns = { };

        #?? man sway-bar
        bars = []; # Disable swaybars

        # https://i3wm.org/docs/userguide.html#client_colors
        colors = let
          common = {
            background = "#002b36";
            border = "#073642";
            childBorder = "#073642";
            indicator = "#d33682";
            text = "#93a1a1";
          };
        in {
          background = common.background;

          focused =
            common
            // {
              background = "#6c71c4";
              border = "#6c71c4";
              childBorder = "#6c71c4";
              text = "#002b36";
            };

          focusedInactive =
            common
            // {
              border = "#93a1a1";
              childBorder = "#93a1a1";
            };

          unfocused =
            common
            // {
              border = "#002b36";
              childBorder = "#002b36";
            };

          urgent = common;
        };

        # BUG: floating_modifier does not clear release binds
        # https://github.com/swaywm/sway/issues/4505
        #// floating = { };

        focus = {
          # BUG: Does not switch workspace on activation
          # https://github.com/swaywm/sway/issues/7912
          newWindow = "focus";

          wrapping = "force";
        };

        fonts.size = 11.0;

        # BUG: Other gaps may disable swayfx corners, fixed in master
        # https://github.com/WillPower3309/swayfx/issues/93
        # https://github.com/swaywm/sway/pull/8017
        gaps.inner = 20;

        modes = {}; # Disable modes

        #?? wev
        modifier = "Mod4";

        # https://i3wm.org/docs/userguide.html#_automatically_starting_applications_on_i3_startup
        startup = let
          # Wrap exec in quotes
          #?? <always|once> "COMMAND"
          always = command: {command = "'${command}'";};
          once = command: {command = "'${command}'";};
        in [
          # (always "${pkill} sway-audio-idle-inhibit; ${sway-audio-idle-inhibit}")
          # (always "${pkill} vrr-fs; vrr-fs")

          # # TODO: Use graphical-session.target when merged upstream
          # # https://github.com/NixOS/nixpkgs/pull/218716
          # (always "${pkill} waybar; ${waybar}")

          # (once "${rm} ~/.config/qalculate/qalc.dmenu.history") # Clear calc history
          # (once "${rm} ~/.cache/cliphist/db") # Clear clipboard database
        ];
      };

      #!! Applies to every move/workspace invocation
      # The inverse of --no-auto-back-and-forth would be preferable
      #// workspaceAutoBackAndForth = true;

      #// workspaceLayout = "";

      #// workspaceOutputAssign = [ ];

      # Commands not currently configurable via options
      extraConfig = ''
        default_border pixel 2

        # BUG: Does not work
        # https://github.com/swaywm/sway/issues/7360
        default_floating_border normal 0

        # BUG: Unknown/invalid command
        #// primary_selection disabled

        titlebar_border_thickness 2

        workspace 1
      '';
    };
  };
}
