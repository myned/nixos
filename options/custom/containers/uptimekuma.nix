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
        depends_on = ["vpn"];
        image = "ghcr.io/louislam/uptime-kuma:2.0.0-beta.3"; # https://github.com/louislam/uptime-kuma/pkgs/container/uptime-kuma
        network_mode = "service:vpn"; # 3001/tcp
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/uptimekuma/data:/app/data"];
      };

      # https://tailscale.com/kb/1282/docker
      vpn.service = {
        container_name = "uptimekuma-vpn";
        devices = ["/dev/net/tun:/dev/net/tun"];
        env_file = [config.age.secrets."common/tailscale/container.env".path];
        hostname = "${config.custom.hostname}-uptimekuma";
        image = "ghcr.io/tailscale/tailscale:v1.84.3"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/uptimekuma/vpn:/var/lib/tailscale"];

        capabilities = {
          NET_ADMIN = true;
        };
      };
    };
  };
}
