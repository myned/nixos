{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.uptimekuma;
in {
  options.custom.containers.uptimekuma = {
    enable = mkEnableOption "uptimekuma";
  };

  config = mkIf cfg.enable {
    #?? arion-uptimekuma pull
    environment.shellAliases.arion-uptimekuma = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.uptimekuma.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.uptimekuma.settings.services = {
      # https://uptime.kuma.pet/
      # https://github.com/louislam/uptime-kuma
      # https://github.com/louislam/uptime-kuma/blob/master/compose.yaml
      uptimekuma.service = {
        container_name = "uptimekuma";
        dns = ["100.100.100.100"]; # Tailscale resolver
        image = "louislam/uptime-kuma:2.0.0-beta.2";
        network_mode = "host"; # 3001/tcp
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/uptimekuma/data:/app/data"];
      };
    };
  };
}
