{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.games._7-days-to-die;
in {
  options.custom.games._7-days-to-die = {
    enable = mkEnableOption "_7-days-to-die";

    openFirewall = mkOption {
      default = !config.custom.services.tailscale.enable;
      description = "Whether to open ports in the firewall for the dedicated server";
      example = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://www.protondb.com/app/251570
    # https://www.pcgamingwiki.com/wiki/7_Days_to_Die
    # https://developer.valvesoftware.com/wiki/7_Days_to_Die_Dedicated_Server
    networking.firewall = optionalAttrs cfg.openFirewall {
      allowedTCPPorts = [26900];

      allowedUDPPortRanges = [
        {
          from = 26900;
          to = 26903;
        }
      ];
    };

    systemd.user.tmpfiles.rules = [
      "L+ ${config.custom.games.steamDir}/251570/pfx/drive_c/users/steamuser/AppData/Roaming/7DaysToDie/Saves - - - - ${config.custom.sync}/game/saves/7-days-to-die/${config.custom.username}/Saves"
    ];
  };
}
