{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.actualbudget;
  containerCfg = config.containers.actualbudget;
  hostCfg = config;
in {
  options.custom.containers.actualbudget = {
    enable = mkEnableOption "actualbudget";
  };

  config = mkIf cfg.enable {
    containers.actualbudget.config = {
      # https://actualbudget.org/
      # https://github.com/actualbudget/actual
      services.actual = {
        enable = true;

        # https://actualbudget.org/docs/config/
        #?? <setting>._secret = "<path>";
        settings = {
          hostname = "::";
          port = 80; # TCP
          trustedProxies = [
            "192.168.0.0/16"
            "172.16.0.0/12"
            "100.64.0.0/10" # Tailscale
            "127.0.0.0/8"
            "10.0.0.0/8"
            "::1/128"
            "fd7a:115c:a1e0::/48" # Tailscale
            "fc00::/7"
          ];
        };
      };

      systemd.services.actual.serviceConfig = {
        PrivateUsers = mkForce false; # To use granted capabilities
        AmbientCapabilities = mkForce ["CAP_NET_BIND_SERVICE"]; # For binding to ports < 1024
        CapabilityBoundingSet = mkForce ["CAP_NET_BIND_SERVICE"];
      };
    };
  };
}
