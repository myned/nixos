{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.steam;
in {
  # https://wiki.nixos.org/wiki/Steam
  # https://store.steampowered.com
  options.custom.programs.steam = {
    enable = mkOption {default = false;};
    extest = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    programs.steam =
      {
        enable = true;
        extest.enable = cfg.extest; # Work around invisible cursor on Wayland
        extraCompatPackages = [pkgs.proton-ge-bin];

        # HACK: Work around black main window with xwayland-satellite
        # https://github.com/ValveSoftware/steam-for-linux/issues/10543 et al.
        package = mkIf config.custom.services.xwayland-satellite.enable (
          pkgs.steam.override {
            extraArgs = "-system-composer";
          }
        );
      }
      // optionalAttrs (versionAtLeast version "24.11") {protontricks.enable = true;};
  };
}
