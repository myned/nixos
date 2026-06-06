{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.lockscreens.gtklock;
in {
  options.custom.lockscreens.gtklock = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # Manually create entry in PAM in lieu of official module
    # https://github.com/NixOS/nixpkgs/issues/240886
    security.pam.services.gtklock = {};

    # https://github.com/jovanlanik/gtklock
    environment.systemPackages = [pkgs.gtklock];
  };
}
