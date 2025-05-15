{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.hyprlock;
in {
  options.custom.programs.hyprlock = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    programs.hyprlock.enable = true; # Grant PAM access

    home-manager.sharedModules = [
      {
        # https://github.com/hyprwm/hyprlock
        programs.hyprlock = {
          enable = true;

          # https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock
          settings = {
            # https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/#general
            general = {
              disable_loading_bar = true;
              #// grace = 60; # Seconds
              #// hide_cursor = true;
              #// ignore_empty_input = true;
              immediate_render = true;
            };

            # https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/#authentication
            auth = {
              "fingerprint:enabled" = true;
              "fingerprint:present_message" = "<span foreground='##d33682'>󰈷</span>";
              "fingerprint:ready_message" = "󰈷";
            };

            # https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/#background
            background = {
              blur_passes = 5;
              color = "rgb(073642)"; # Fallback
              path = mkIf config.custom.services.wallpaper.enable "/tmp/wallpaper.png";
            };

            # https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/#input-field
            input-field = {
              capslock_color = "rgb(cb4b16)";
              check_color = "rgb(859900)";
              fade_on_empty = false;
              fade_timeout = 0;
              fail_color = "rgb(dc322f)";
              fail_text = "";
              font_color = "rgb(eee8d5)";
              inner_color = "rgb(002b36)";
              outer_color = "rgb(d33682)";
              outline_thickness = 3;
              placeholder_text = "";
              position = "0, 0";
              size = "500, 50";
            };

            # https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock/#label
            label = [
              {
                # Time
                color = "rgb(fdf6e3)";
                font_family = "monospace";
                font_size = 64;
                halign = "center";
                position = "0, 200";
                text_align = "center";
                valign = "center";
                text =
                  if config.custom.time == "24h"
                  then "$TIME"
                  else "$TIME12";
              }

              {
                # Date
                color = "rgb(eee8d5)";
                font_family = "monospace";
                font_size = 32;
                halign = "center";
                position = "0, 100";
                text = ''cmd[update:60000] echo "$(date +'%a %b %d')"''; # Sun Jan 01
                text_align = "center";
                valign = "center";
              }

              {
                # Fingerprint
                color = "rgb(eee8d5)";
                font_family = "monospace";
                font_size = 42;
                halign = "center";
                position = "0, -100";
                text = "$FPRINTPROMPT";
                text_align = "center";
                valign = "center";
              }
            ];
          };
        };

        # TODO: Use stylix
        # https://stylix.danth.me/options/modules/hyprlock.html
        stylix.targets.hyprlock.enable = false;
      }
    ];
  };
}
