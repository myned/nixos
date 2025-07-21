{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.headscale;
in {
  options.custom.containers.headscale = {
    enable = mkEnableOption "headscale";
  };

  config = mkIf cfg.enable {
    #?? arion-headscale pull
    environment.shellAliases.arion-headscale = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.headscale.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.headscale.settings.services = {
      # BUG: Does not support generic DoH/DoT
      # https://github.com/juanfont/headscale/issues/1312
      # https://headscale.net/
      # https://github.com/juanfont/headscale
      # https://headscale.net/stable/setup/install/container/
      headscale.service = {
        command = "serve";
        container_name = "headscale";
        image = "ghcr.io/juanfont/headscale:v0.26.1"; # https://github.com/juanfont/headscale/pkgs/container/headscale
        restart = "unless-stopped";

        ports = [
          "3480:3480/udp" # STUN
          #// "9090:9090/tcp" # Metrics
          "9999:9999/tcp" # Server
        ];

        volumes = [
          "${config.age.secrets."${config.custom.hostname}/headscale/config.yaml".path}:/etc/headscale/config.yaml:ro"
          "${config.age.secrets."${config.custom.hostname}/headscale/policy.hujson".path}:/etc/headscale/policy.hujson:ro"
          "${config.custom.containers.directory}/headscale/data:/var/lib/headscale"
        ];
      };

      # https://github.com/tale/headplane
      # https://github.com/tale/headplane/blob/main/docs/Simple-Mode.md
      #?? arion-headscale exec headscale -- headscale apikeys create --expiration 1y
      #?? arion-headscale exec headscale -- headscale preauthkeys create --expiration 99y --reusable --user <id>
      ui.service = {
        container_name = "headscale-ui";
        image = "ghcr.io/tale/headplane:0.6.0"; # https://github.com/tale/headplane/pkgs/container/headplane
        restart = "unless-stopped";
        ports = ["3003:3003/tcp"];

        volumes = [
          "${config.age.secrets."${config.custom.hostname}/headscale/config.yaml".path}:/etc/headscale/config.yaml:ro"
          "${config.age.secrets."${config.custom.hostname}/headscale/ui.yaml".path}:/etc/headplane/config.yaml:ro"
          "${config.custom.containers.directory}/headscale/ui/data:/var/lib/headplane"
        ];
      };
    };

    networking.firewall = {
      allowedUDPPorts = [3480]; # STUN
    };

    age.secrets = listToAttrs (map (name: {
        inherit name;
        value = {file = "${inputs.self}/secrets/${name}";};
      })
      [
        "${config.custom.hostname}/headscale/config.yaml"
        "${config.custom.hostname}/headscale/policy.hujson"
        "${config.custom.hostname}/headscale/ui.yaml"
      ]);
  };
}
