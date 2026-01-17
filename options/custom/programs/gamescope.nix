{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.gamescope;
in {
  options.custom.programs.gamescope = {
    enable = mkEnableOption "gamescope";

    width = mkOption {
      description = "Width of the gamescope output display";
      default = config.custom.display.default.height * 16 / 9;
      example = 1920;
      type = types.int;
    };

    height = mkOption {
      description = "Height of the gamescope output display";
      default = config.custom.display.default.height;
      example = 1080;
      type = types.int;
    };
  };

  config = mkIf cfg.enable {
    # https://github.com/ValveSoftware/gamescope
    #!! Issues may arise depending on environment
    # https://github.com/NixOS/nixpkgs/issues/162562#issuecomment-1523177264
    programs.gamescope = {
      enable = true;
      capSysNice = true; # Allow renice

      args = [
        "--rt"
        "--force-grab-cursor"
        "--fullscreen"
        "--backend=sdl" # auto|drm|sdl|openvr|wayland
        "--output-width=${toString cfg.width}"
        "--output-height=${toString cfg.height}"
      ];
    };
  };
}
