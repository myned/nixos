{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.containers.synapseadmin;
in {
  options.custom.containers.synapseadmin = {
    enable = mkEnableOption "synapseadmin";
  };

  config = mkIf cfg.enable {
    #?? arion-synapse-admin pull
    environment.shellAliases.arion-synapseadmin = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.synapseadmin.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.synapseadmin.settings.services = {
      # https://github.com/etkecc/synapse-admin
      # https://github.com/etkecc/synapse-admin/blob/main/docker-compose.yml
      synapseadmin.service = {
        container_name = "synapseadmin";
        image = "ghcr.io/etkecc/synapse-admin:v0.11.1-etke45"; # https://github.com/etkecc/synapse-admin/pkgs/container/synapse-admin
        ports = ["8000:80/tcp"];
        restart = "unless-stopped";

        volumes = let
          # https://github.com/etkecc/synapse-admin/blob/main/docs/config.md
          configuration = pkgs.writeText "config.json" (generators.toJSON {} {
            restrictBaseUrl = ["https://matrix.bjork.tech"];
          });
        in [
          "${configuration}:/app/config.json:ro"
        ];
      };
    };
  };
}
