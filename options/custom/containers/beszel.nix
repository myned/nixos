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
    virtualisation.arion.projects.beszel.settings.services =
      {
        # https://beszel.dev/guide/agent-installation
        agent.service = {
          container_name = "beszel-agent";
          image = "ghcr.io/henrygd/beszel/beszel-agent:0.10"; # https://github.com/henrygd/beszel/pkgs/container/beszel%2Fbeszel-agent
          network_mode = "host"; # 45876/tcp
          restart = "unless-stopped";
          volumes = ["/var/run/docker.sock:/var/run/docker.sock:ro"];

          # https://beszel.dev/guide/environment-variables#agent
          environment = {
            KEY = cfg.key;
            LISTEN = "${config.custom.services.tailscale.ip}:45876";
          };
        };
      }
      // optionalAttrs cfg.server {
        # https://beszel.dev/guide/hub-installation
        beszel.service = {
          container_name = "beszel";
          dns = ["100.100.100.100"]; # Tailscale resolver
          image = "ghcr.io/henrygd/beszel/beszel:0.10"; # https://github.com/henrygd/beszel/pkgs/container/beszel%2Fbeszel
          ports = ["${config.custom.services.tailscale.ip}:8090:8090/tcp"];
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/beszel/data:/beszel_data"];
        };
      };
  };
}
