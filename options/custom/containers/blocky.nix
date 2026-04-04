{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.blocky;
  containerCfg = config.containers.blocky;
  hostCfg = config;
in {
  options.custom.containers.blocky = {
    enable = mkEnableOption "blocky";
  };

  config = mkIf cfg.enable {
    containers.blocky.config = {
      # https://wiki.nixos.org/wiki/Blocky
      services.blocky = {
        enable = true;

        # https://0xerr0r.github.io/blocky/configuration/
        settings = {
          upstreams = {
            strategy = "parallel_best";
            init.strategy = "failOnError";
            groups.default = [
              "https://dns.quad9.net/dns-query" # https://quad9.net/service/service-addresses-and-features/
            ];
          };

          customDNS.mapping = {
            ${hostCfg.custom.domain} = concatStringsSep "," (with inputs.self.nixosConfigurations.myore.config.custom.services.tailscale; [
              ipv4
              ipv6
            ]);
          };
        };
      };

      services.resolved.extraConfig = "DNSStubListener=false"; # Allow binding to :53
      services.tailscale.extraUpFlags = ["--accept-dns=false"]; # Do not use Tailscale resolvers because this is a resolver
    };
  };
}
