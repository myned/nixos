{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.nautilus;
in {
  options.custom.programs.nautilus.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    services.gvfs.enable = true; # Trash dependency

    # Fix nautilus extension environment
    # https://github.com/NixOS/nixpkgs/pull/240780
    #?? echo $NAUTILUS_4_EXTENSION_DIR
    services.gnome = {
      core-utilities.enable = true; # Required to set environment variables
      sushi.enable = true; # Quick preview with spacebar
    };

    environment.systemPackages = with pkgs; [
      nautilus
      nautilus-open-in-blackbox
      nautilus-python
    ];
  };
}
