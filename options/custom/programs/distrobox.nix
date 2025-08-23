{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.distrobox;
in {
  options.custom.programs.distrobox = {
    enable = mkEnableOption "distrobox";
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://distrobox.it/
      # https://github.com/89luca89/distrobox
      programs.distrobox = {
        enable = true;

        # https://github.com/89luca89/distrobox/blob/main/docs/usage/distrobox-assemble.md
        containers = {};
      };
    };

    # https://github.com/ranfdev/DistroShelf
    environment.systemPackages = [pkgs.distroshelf]; # GUI manager
  };
}
