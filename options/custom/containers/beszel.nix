{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.beszel;
in {
  options.custom.containers.beszel = {
    enable = mkEnableOption "beszel";

    agent = mkOption {
      default = true;
      type = types.bool;
    };

    key = mkOption {
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ4ESP/UERllv2j58bZMRhctAVjpikKIkrYsFWVSPmYe";
      type = types.str;
    };

    server = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    #?? arion-beszel pull
    environment.shellAliases.arion-beszel = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.beszel.settings.out.dockerComposeYaml}";

    # https://beszel.dev/
    # https://github.com/henrygd/beszel
    # https://beszel.dev/guide/hub-installation
    virtualisation.arion.projects.beszel.settings.services =
      optionalAttrs cfg.server {
        beszel.service = {
          container_name = "beszel";
          depends_on = ["vpn"];
          image = "ghcr.io/henrygd/beszel/beszel:latest"; # https://github.com/henrygd/beszel/pkgs/container/beszel%2Fbeszel
          network_mode = "service:vpn"; # 8090/tcp
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/beszel/data:/beszel_data"];
        };

        # https://tailscale.com/kb/1282/docker
        vpn.service = {
          container_name = "beszel-vpn";
          devices = ["/dev/net/tun:/dev/net/tun"];
          env_file = [config.age.secrets."common/tailscale/container.env".path];
          hostname = "${config.custom.hostname}-beszel";
          image = "ghcr.io/tailscale/tailscale:latest"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/beszel/vpn:/var/lib/tailscale"];

          capabilities = {
            "NET_ADMIN" = true;
          };
        };
      }
      // optionalAttrs cfg.agent {
        # https://beszel.dev/guide/agent-installation
        agent.service = {
          container_name = "beszel-agent";
          image = "ghcr.io/henrygd/beszel/beszel-agent:latest"; # https://github.com/henrygd/beszel/pkgs/container/beszel%2Fbeszel-agent
          network_mode = "host"; # 45876/tcp
          restart = "unless-stopped";
          volumes = ["/var/run/docker.sock:/var/run/docker.sock:ro"];

          # https://beszel.dev/guide/environment-variables#agent
          environment = {
            KEY = cfg.key;
            LISTEN = "${config.custom.services.tailscale.ip}:45876";
          };
        };
      };
  };
}
