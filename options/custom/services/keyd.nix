{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.keyd;
in {
  options.custom.services.keyd = {
    enable = mkEnableOption "keyd";
  };

  config = mkIf cfg.enable {
    # https://github.com/rvaiya/keyd
    environment.systemPackages = [pkgs.keyd];

    #?? keyd list-keys
    #!! xkb options overlap with keyd binds
    services.keyd = {
      enable = true;

      # https://github.com/rvaiya/keyd/blob/master/docs/keyd.scdoc
      #?? keyd monitor
      keyboards.default = {
        ids = [
          "*"
          "-1234:5678:b980a419" # extest
          "-2333:6666:69419150" # ydotool
        ];

        settings = {
          main = {
            capslock = "backspace";
            backspace = "delete";

            # compose = "layer(function)";
            leftmeta = "layer(alt)";
            rightmeta = "layer(alt)";
            leftcontrol = "layer(control)";
            rightcontrol = "layer(control)";
            leftalt = "layer(meta)";
            rightalt = "layer(meta)";
          };

          shift.shift = "capslock"; # Both Shifts toggle Capslock

          # meta.control.shift.esc = {
          #   # Mouse repeat macro
          #   "," = "macro2(300, 100, leftmouse)";
          #   "." = "macro2(300, 100, rightmouse)";
          #   "/" = "macro2(300, 100, middlemouse)";
          # };

          # Emulate function keys
          # function = {
          #   space = "playpause";
          #   rightalt = "previoussong";
          #   rightcontrol = "nextsong";
          #   backspace = "mute";
          #   minus = "volumedown";
          #   equal = "volumeup";

          #   ";" = "pageup";
          #   "." = "pagedown";
          #   "'" = "home";
          #   "/" = "end";
          #   "\\" = "sysrq"; # Printscreen
          # };
        };
      };
    };
  };
}
