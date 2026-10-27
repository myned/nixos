{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.xserver;
in {
  options.custom.services.xserver = {
    enable = mkEnableOption "xserver";

    options = mkOption {
      description = "List of default xkb options";
      default = ["caps:capslock" "grp:alt_caps_toggle"];
      example = ["shift:both_capslock_cancel"];
      type = with types; listOf str;
    };

    extraOptions = mkOption {
      description = "List of xkb options to append to default options";
      default = [];
      example = ["caps:backspace"];
      type = with types; listOf str;
    };
  };

  config = mkIf cfg.enable {
    #!! Xserver options are used even on Wayland
    services.xserver = {
      enable = true;
      exportConfiguration = true;

      # https://wiki.nixos.org/wiki/Keyboard_Layout_Customization
      xkb = {
        layout = "us,us";
        variant = "colemak,,"; # https://github.com/NixOS/nixpkgs/issues/359830
        options = concatStringsSep "," (cfg.options ++ cfg.extraOptions); #?? less -p option /etc/X11/xkb/rules/base.lst
      };
    };
  };
}
