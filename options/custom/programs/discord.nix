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
      default = "vesktop";
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

    home-manager.sharedModules = [
      {
        # https://github.com/Vencord/Vesktop
        programs.vesktop = mkIf (cfg.client == "vesktop") {
          enable = true;
          vencord.useSystem = true;

          # https://github.com/Vencord/Vesktop/blob/main/src/shared/settings.d.ts
          settings = {
            customTitleBar = true;
            disableMinSize = true;
            enableSplashScreen = false;
            hardwareAcceleration = true;
            hardwareVideoAcceleration = true;
            tray = false;
          };
        };

        # https://betterdiscord.app/
        # https://github.com/BetterDiscord/BetterDiscord
        #!! Imperative config and patching
        #?? betterdiscordctl install
        xdg.configFile = mkIf (cfg.client == "betterdiscord") {
          "BetterDiscord" = {
            force = true;
            source = hm.lib.file.mkOutOfStoreSymlink "${config.custom.syncDir}/common/config/discord/BetterDiscord";
          };
        };

        # https://nix-community.github.io/stylix/options/modules/discord.html
        #// stylix.targets.vesktop.enable = cfg.client == "vesktop";
      }
    ];
  };
}
