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
      default = 1280;
      description = "Width of the gamescope output display";
      example = 1920;
      type = types.int;
    };

    height = mkOption {
      default = 800;
      description = "Height of the gamescope output display";
      example = 1080;
      type = types.int;
    };

    refresh = mkOption {
      default = 60;
      description = "Refresh rate of the gamescope nested window";
      example = 120;
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
        "--output-width=${toString cfg.width}"
        "--output-height=${toString cfg.height}"
        "--nested-refresh=${toString cfg.refresh}"
      ];
    };
  };
}
