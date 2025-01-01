{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.keyd;
in {
  options.custom.services.keyd.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://github.com/rvaiya/keyd
    #?? keyd list-keys
    #!! Enabling xkeyboard-config layouts will underlap with keyd binds
    services.keyd = {
      enable = true;

      #!! Binds use qwerty without layouts
      # https://github.com/rvaiya/keyd/blob/master/docs/keyd.scdoc
      #?? keyd monitor
      keyboards.default.settings = {
        #// global.disable_modifier_guard = 1; # Disable extraneous Control injection

        control.esc = "toggle(qwerty)"; # Control+Esc toggles qwerty
        shift.shift = "capslock"; # Both Shifts toggle Capslock

        meta = {
          # Mouse repeat macro
          "," = "macro2(300, 100, leftmouse)";
          "." = "macro2(300, 100, rightmouse)";
          "/" = "macro2(300, 100, middlemouse)";
        };

        # Emulate function keys
        function = {
          space = "playpause";
          rightalt = "previoussong";
          rightcontrol = "nextsong";
          backspace = "mute";
          minus = "volumedown";
          equal = "volumeup";

          ";" = "pageup";
          "." = "pagedown";
          "'" = "home";
          "/" = "end";
          "\\" = "sysrq"; # Printscreen
        };

        qwerty = {
          capslock = "capslock";
          backspace = "backspace";

          "w" = "w";
          "," = ",";
          "s" = "s";
          "a" = "a";
          "c" = "c";
          "g" = "g";
          "q" = "q";
          "e" = "e";
          "]" = "]";
          "d" = "d";
          "/" = "/";
          ";" = ";";
          "'" = "'";
          "r" = "r";
          "f" = "f";
          "t" = "t";
          "u" = "u";
          "." = ".";
          "j" = "j";
          "k" = "k";
          "p" = "p";
          "o" = "o";
          "z" = "z";
          "h" = "h";
          "i" = "i";
          "[" = "[";
          "v" = "v";
          "l" = "l";
          "m" = "m";
          "n" = "n";
          "x" = "x";
          "b" = "b";
          "y" = "y";
        };

        main = {
          capslock = "backspace";
          backspace = "delete";

          compose = "layer(function)";
          leftmeta = "layer(alt)";
          leftalt = "layer(meta)";
          rightalt = "layer(meta)";

          # Colemak default
          "w" = "w";
          "," = ",";
          "s" = "r";
          "a" = "a";
          "c" = "c";
          "g" = "d";
          "q" = "q";
          "e" = "f";
          "]" = "]";
          "d" = "s";
          "/" = "/";
          ";" = "o";
          "'" = "'";
          "r" = "p";
          "f" = "t";
          "t" = "g";
          "u" = "l";
          "." = ".";
          "j" = "n";
          "k" = "e";
          "p" = ";";
          "o" = "y";
          "z" = "z";
          "h" = "h";
          "i" = "u";
          "[" = "[";
          "v" = "v";
          "l" = "i";
          "m" = "m";
          "n" = "k";
          "x" = "x";
          "b" = "b";
          "y" = "j";
        };
      };
    };
  };
}
