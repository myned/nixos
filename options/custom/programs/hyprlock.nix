{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.hyprlock;
in {
  options.custom.programs.hyprlock.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    programs.hyprlock.enable = true; # Grant PAM access

    # https://github.com/hyprwm/hyprlock
    home-manager.users.${config.custom.username}.programs.hyprlock = {
      enable = true;

      # https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock
      # https://wiki.hyprland.org/Hypr-Ecosystem/hyprlang/#comments
      settings = {
        general = {
          disable_loading_bar = true;
          enable_fingerprint = true; # Enter not required
          fingerprint_present_message = "<span foreground='##d33682'>󰈷</span>";
          fingerprint_ready_message = "󰈷";
          grace = 5 * 60; # Seconds
          hide_cursor = true;
          ignore_empty_input = true;
          no_fade_in = true; # Fix suspend interrupting animation
        };

        background = {
          blur_passes = 5;
          color = "rgb(073642)"; # Fallback
          path = "/tmp/wallpaper.png";
        };

        input-field = {
          capslock_color = "rgb(cb4b16)";
          check_color = "rgb(859900)";
          fade_on_empty = false;
          fade_timeout = 0;
          fail_color = "rgb(dc322f)";
          fail_text = "";
          font_color = "rgb(93a1a1)";
          inner_color = "rgb(002b36)";
          outer_color = "rgb(d33682)";
          outline_thickness = 3;
          placeholder_text = "";
          position = "0, 0";
          size = "500, 50";
        };

        label = [
          # Time
          {
            color = "rgb(93a1a1)";
            font_family = config.custom.font.sans-serif;
            font_size = 64;
            halign = "center";
            position = "0, 200";

            # BUG: Noon displayed as 00:00, fixed > v0.5.0
            # https://github.com/hyprwm/hyprlock/issues/552
            #// text = "$TIME12";
            text = ''cmd[update:1000] echo "$(date +'%I:%M %p')"''; # 12:00 AM

            text_align = "center";
            valign = "center";
          }

          # Date
          {
            color = "rgb(93a1a1)";
            font_family = config.custom.font.sans-serif;
            font_size = 32;
            halign = "center";
            position = "0, 100";
            text = ''cmd[update:60000] echo "$(date +'%a %b %d')"''; # Sun Jan 01
            text_align = "center";
            valign = "center";
          }

          # Fingerprint
          {
            color = "rgb(93a1a1)";
            font_family = config.custom.font.monospace;
            font_size = 42;
            halign = "center";
            position = "0, -100";
            text = "$FPRINTMESSAGE";
            text_align = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}
