{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.syncthing;
in {
  options.custom.containers.syncthing = {
    enable = mkEnableOption "syncthing";

    server = mkOption {
      default = false;
      description = "Whether to enable the discovery and relay server and disable synchronization";
      example = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.hostname}/syncthing/.env" = secret "${config.custom.hostname}/syncthing/.env";
    };

    #?? arion-syncthing pull
    environment.shellAliases.arion-syncthing = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.syncthing.settings.out.dockerComposeYaml}";

    # https://github.com/syncthing/syncthing/blob/main/README-Docker.md
    virtualisation.arion.projects.syncthing.settings.services =
      # TODO: Syncthing configuration
      optionalAttrs (!cfg.server) {
        syncthing.service = {
          container_name = "syncthing";
          depends_on = ["vpn"];
          env_file = [config.age.secrets."${config.custom.hostname}/syncthing/.env".path];
          image = "ghcr.io/syncthing/syncthing:1.30.0"; # https://github.com/syncthing/syncthing/pkgs/container/syncthing
          network_mode = "service:vpn"; # 8384/tcp 21027/udp 22000/tcp/udp
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/syncthing/data:/data"];
        };
      }
      # https://docs.syncthing.net/users/stdiscosrv.html
      // optionalAttrs cfg.server {
        discovery.service = {
          command = "--http";
          container_name = "syncthing-discovery";
          depends_on = ["vpn"];
          image = "ghcr.io/syncthing/discosrv:1.30.0"; # https://github.com/syncthing/syncthing/pkgs/container/discosrv
          network_mode = "service:vpn"; # 8443/tcp
          restart = "unless-stopped";
        };

        # TODO: Relay server
        # https://docs.syncthing.net/users/strelaysrv.html
        relay.service = {
          container_name = "syncthing-relay";
          depends_on = ["vpn"];
          image = "ghcr.io/syncthing/relaysrv:1.30.0"; # https://github.com/syncthing/syncthing/pkgs/container/relaysrv
          network_mode = "service:vpn"; # 22067/tcp
          restart = "unless-stopped";
        };
      }
      // {
        # https://tailscale.com/kb/1282/docker
        vpn.service = {
          container_name = "syncthing-vpn";
          devices = ["/dev/net/tun:/dev/net/tun"];
          env_file = [config.age.secrets."common/tailscale/container.env".path];
          hostname = "${config.custom.hostname}-syncthing";
          image = "ghcr.io/tailscale/tailscale:v1.84.3"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/syncthing/vpn:/var/lib/tailscale"];

          capabilities = {
            NET_ADMIN = true;
          };
        };
      };
  };
}
