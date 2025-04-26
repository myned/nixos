{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.owncast;
in {
  options.custom.containers.owncast.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    #?? arion-owncast pull
    environment.shellAliases.arion-owncast = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.owncast.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.owncast.settings.services = {
      owncast.service = {
        container_name = "owncast";
        depends_on = ["vpn"];
        image = "owncast/owncast:latest";
        network_mode = "service:vpn"; # 8080/tcp
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/owncast/data:/app/data"];
      };

      # https://tailscale.com/kb/1282/docker
      vpn.service = {
        container_name = "owncast-vpn";
        devices = ["/dev/net/tun:/dev/net/tun"];
        env_file = [config.age.secrets."common/tailscale/container.env".path];
        hostname = "owncast";
        image = "ghcr.io/tailscale/tailscale:latest"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/owncast/vpn:/var/lib/tailscale"];

        capabilities = {
          NET_ADMIN = true;
        };

        # ports = [
        #   "127.0.0.1:8800:8080/tcp" # HTTP
        #   "1935:1935/tcp" # RTMP
        # ];
      };
    };

    # networking.firewall = {
    #   allowedTCPPorts = [
    #     1935 # RTMP
    #   ];
    # };
  };
}
