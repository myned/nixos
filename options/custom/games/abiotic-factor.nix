{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.games.abiotic-factor;
in {
  options.custom.games.abiotic-factor = {
    enable = mkEnableOption "abiotic-factor";

    openFirewall = mkOption {
      default = !config.custom.services.tailscale.enable;
      description = "Whether to open ports in the firewall for the dedicated server";
      example = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://www.protondb.com/app/427410
    # https://www.pcgamingwiki.com/wiki/Abiotic_Factor
    # https://github.com/DFJacob/AbioticFactorDedicatedServer
    networking.firewall = optionalAttrs cfg.openFirewall {
      allowedTCPPorts = [7777 27015];
      allowedUDPPorts = [7777 27015];
    };

    systemd.user.tmpfiles.rules = [
      "L+ ${config.custom.games.steamDir}/../common/Abiotic Factor Dedicated Server/AbioticFactor/Saved/SaveGames/Server/Worlds - - - - ${config.custom.sync}/game/saves/abiotic-factor/${config.custom.username}/Worlds"
    ];
  };
}
