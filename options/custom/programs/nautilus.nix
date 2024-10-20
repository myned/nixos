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
    services = {
      gnome.sushi.enable = true; # Quick preview with spacebar
      gvfs.enable = true; # Trash dependency
    };

    # Alternative fix to services.gnome.core-utilities.enable
    # https://github.com/NixOS/nixpkgs/pull/240780
    #?? echo $NAUTILUS_4_EXTENSION_DIR
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "kitty";
    };

    # TODO: Use module when completed
    # https://github.com/NixOS/nixpkgs/pull/319535
    environment.systemPackages = with pkgs; [
      nautilus
      nautilus-open-in-blackbox
      nautilus-python
    ];
  };
}
