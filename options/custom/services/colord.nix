{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.colord;
in {
  options.custom.services.colord = {
    enable = mkEnableOption "colord";
  };

  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/ICC_profiles
    #!! Imperative usage
    #?? colormgr import-profile <profile>
    # https://github.com/NixOS/nixpkgs/issues/284338
    # https://github.com/jottr/nixos-hardware/issues/2
    services.colord.enable = true;

    environment.systemPackages = [pkgs.gnome-color-manager];
  };
}
