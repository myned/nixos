{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.containers.uptimekuma;
  containerCfg = config.containers.uptimekuma;
  hostCfg = config;
in {
  options.custom.containers.uptimekuma = {
    enable = mkEnableOption "uptimekuma";
  };

  config = mkIf cfg.enable {
    containers.uptimekuma.config = {
      services.uptime-kuma = {
        enable = true;
        package = pkgs.unstable.uptime-kuma;

        # https://github.com/louislam/uptime-kuma/wiki/Environment-Variables
        settings = {
          HOST = "::";
          PORT = "80";
        };
      };

      systemd.services.uptime-kuma.serviceConfig = {
        PrivateUsers = mkForce false; # To use granted capabilities
        AmbientCapabilities = mkForce ["CAP_NET_BIND_SERVICE"]; # For binding to ports < 1024
        CapabilityBoundingSet = mkForce ["CAP_NET_BIND_SERVICE"];
      };
    };
  };
}
