{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.hyprlock;
in
{
  options.custom.programs.hyprlock.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    programs.hyprlock.enable = true; # Grant PAM access

    # https://wiki.hyprland.org/Hypr-Ecosystem/hyprlock
    # https://github.com/hyprwm/hyprlock
    home-manager.users.${config.custom.username}.programs.hyprlock = {
      enable = true;

      settings = {
        general = {
          grace = 5 * 60; # Seconds
          hide_cursor = true;
          immediate_render = true;
        };

        background = {
          blur_passes = 5;
          color = "rgb(073642)";
          path = "/tmp/wallpaper.png";
        };

        input-field = {
          capslock_color = "rgb(cb4b16)";
          check_color = "rgb(859900)";
          fade_timeout = 0;
          fail_color = "rgb(dc322f)";
          fail_text = "";
          font_color = "rgb(fdf6e3)";
          inner_color = "rgb(002b36)";
          outer_color = "rgb(fdf6e3)";
          outline_thickness = 0;
          placeholder_text = "";
          position = "0, 0";
          shadow_passes = 1;
          shadow_size = 2;
          size = "300, 50";
        };

        label = {
          color = "rgb(fdf6e3)";
          font_family = "monospace";
          font_size = 48;
          halign = "center";
          position = "0, 200";
          text_align = "center";
          valign = "center";

          #     12:00 AM
          # Sunday, January 01
          text = "cmd[update:1000] echo \"<span allow_breaks='true'>$(date +'%I:%M %p<br/><small>%A, %B %d</small>')</span>\"";
        };
      };
    };
  };
}
