{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.games;
in {
  options.custom.settings.games = {
    enable = mkOption {default = false;};
    abiotic-factor = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      # https://github.com/DFJacob/AbioticFactorDedicatedServer
      allowedTCPPorts = optionals cfg.abiotic-factor [
        7777
        27015
      ];

      allowedUDPPorts = optionals cfg.abiotic-factor [
        7777
        27015
      ];
    };
  };
}
