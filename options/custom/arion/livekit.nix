{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.arion.livekit;
in {
  options.custom.arion.livekit = {
    enable = mkEnableOption "livekit";
  };

  config = mkIf cfg.enable {
    #?? arion-livekit pull
    environment.shellAliases.arion-livekit = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.livekit.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.livekit.settings.services = {
      # https://github.com/stoatchat/livekit-server
      livekit.service = {
        command = "--config=/etc/livekit.yaml";
        container_name = "livekit";
        depends_on = ["vpn"];
        image = "docker.io/livekit/livekit-server:v1.9.11"; # https://hub.docker.com/r/livekit/livekit-server/tags
        network_mode = "service:vpn";
        restart = "unless-stopped";
        volumes = ["${config.age.secrets."${config.custom.hostname}/livekit/livekit.yaml".path}:/etc/livekit.yaml:ro"];
      };

      cache.service = {
        container_name = "livekit-cache";
        depends_on = ["vpn"];
        image = "valkey/valkey:8.1.5"; # https://hub.docker.com/r/valkey/valkey/tags
        network_mode = "service:vpn"; # 6379/tcp
        restart = "unless-stopped";
      };

      # https://tailscale.com/kb/1282/docker
      vpn.service = {
        container_name = "livekit-vpn";
        devices = ["/dev/net/tun:/dev/net/tun"];
        env_file = [config.age.secrets."common/tailscale/container.env".path];
        hostname = "${config.custom.hostname}-livekit";
        image = "ghcr.io/tailscale/tailscale:v1.84.3"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
        restart = "unless-stopped";
        volumes = ["${config.custom.arion.directory}/livekit/vpn:/var/lib/tailscale"];

        ports = [
          "7881:7881/tcp"
          "7882:7882/udp"
        ];

        capabilities = {
          NET_ADMIN = true;
        };
      };
    };

    age.secrets = listToAttrs (map (name: {
        inherit name;
        value = {file = "${inputs.self}/secrets/${name}";};
      })
      [
        "${config.custom.hostname}/livekit/livekit.yaml"
      ]);
  };
}
