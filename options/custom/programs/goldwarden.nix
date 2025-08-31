{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.goldwarden;
in {
  options.custom.programs.goldwarden = {
    enable = mkOption {default = false;};
    flatpak = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    # https://github.com/quexten/goldwarden
    programs.goldwarden.enable = true;

    # https://github.com/quexten/goldwarden/wiki/Flatpak-Configuration
    systemd.user.services.goldwarden = mkIf cfg.flatpak {
      environment = {
        GOLDWARDEN_SOCKET_PATH = "%h/.var/app/com.quexten.Goldwarden/data/goldwarden.sock";
      };
    };

    home-manager.users.${config.custom.username} = {
      services.flatpak.packages = mkIf cfg.flatpak ["com.quexten.Goldwarden"];
    };
  };
}
