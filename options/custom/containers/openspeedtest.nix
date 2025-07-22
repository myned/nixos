{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.openspeedtest;
in {
  options.custom.containers.openspeedtest = {
    enable = mkEnableOption "openspeedtest";
  };

  config = mkIf cfg.enable {
    #?? arion-openspeedtest pull
    environment.shellAliases.arion-openspeedtest = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.openspeedtest.settings.out.dockerComposeYaml}";

    # https://openspeedtest.com/
    # https://github.com/openspeedtest/Speed-Test
    virtualisation.arion.projects.openspeedtest.settings.services = {
      openspeedtest.service = {
        container_name = "openspeedtest";
        depends_on = ["vpn"];
        image = "openspeedtest/latest:v2.0.6"; # https://hub.docker.com/r/openspeedtest/latest/tags
        network_mode = "service:vpn"; # 3000/tcp 3001/tcp
        restart = "unless-stopped";
      };

      # https://tailscale.com/kb/1282/docker
      vpn.service = {
        container_name = "openspeedtest-vpn";
        devices = ["/dev/net/tun:/dev/net/tun"];
        env_file = [config.age.secrets."common/tailscale/container.env".path];
        hostname = "${config.custom.hostname}-openspeedtest";
        image = "ghcr.io/tailscale/tailscale:v1.84.3"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/openspeedtest/vpn:/var/lib/tailscale"];

        capabilities = {
          NET_ADMIN = true;
        };
      };
    };
  };
}
