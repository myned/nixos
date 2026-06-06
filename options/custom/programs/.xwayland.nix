{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.xwayland;
in {
  options.custom.programs.xwayland = {
    enable = mkOption {default = false;};
    xwayland-run = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/Wayland#Xwayland
    programs.xwayland.enable = true;

    # https://gitlab.freedesktop.org/ofourdan/xwayland-run
    environment.systemPackages = mkIf cfg.xwayland-run [pkgs.xwayland-run];
  };
}
