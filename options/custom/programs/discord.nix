{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.discord;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.discord = {
    enable = mkEnableOption "discord";

    client = mkOption {
      default = null;
      type = with types; nullOr (enum ["betterdiscord" "dissent" "vesktop"]);
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      optionals (isNull cfg.client) [
        discord
      ]
      ++ optionals (cfg.client == "betterdiscord") [
        betterdiscordctl
      ]
      ++ optionals (cfg.client == "dissent") [
        dissent
      ];

    home-manager.users.${config.custom.username} = {
      # https://github.com/Vencord/Vesktop
      programs.vesktop = mkIf (cfg.client == "vesktop") {
        enable = true;
        vencord.useSystem = true;
      };

      # https://betterdiscord.app/
      # https://github.com/BetterDiscord/BetterDiscord
      #!! Imperative config and patching
      #?? betterdiscordctl install
      xdg.configFile = mkIf (cfg.client == "betterdiscord") {
        "BetterDiscord" = {
          force = true;
          source = hm.lib.file.mkOutOfStoreSymlink "${config.custom.sync}/common/config/discord/BetterDiscord";
        };
      };
    };
  };
}
