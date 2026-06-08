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
  };

  config = mkIf cfg.enable {
    # https://github.com/ValveSoftware/gamescope
    #!! Issues may arise depending on environment
    # https://github.com/NixOS/nixpkgs/issues/162562#issuecomment-1523177264
    programs.gamescope = {
      enable = true;

      # BUG: bwrap: setuid use of bubblewrap is not supported in this build
      # https://github.com/NixOS/nixpkgs/issues/523200
      #// capSysNice = true; # Allow renice

      args = [
        "--force-grab-cursor"
        "--backend=sdl" # auto|drm|sdl|openvr|wayland
      ];
    };
  };
}
