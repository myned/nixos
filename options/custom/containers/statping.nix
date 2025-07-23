{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.statping;
in {
  options.custom.containers.statping = {
    enable = mkEnableOption "statping";
  };

  config = mkIf cfg.enable {
    #?? arion-statping pull
    environment.shellAliases.arion-statping = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.statping.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.statping.settings.services = {
      # https://statping-ng.github.io/
      # https://github.com/statping-ng/statping-ng
      # https://github.com/statping-ng/statping-ng/wiki/Docker
      statping.service = {
        container_name = "statping";
        depends_on = ["vpn"];
        image = "ghcr.io/statping-ng/statping-ng:0.93.0"; # https://github.com/statping-ng/statping-ng/pkgs/container/statping-ng
        network_mode = "service:vpn"; # 8080/tcp
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/statping/data:/app"];
      };

      # https://tailscale.com/kb/1282/docker
      vpn.service = {
        container_name = "statping-vpn";
        devices = ["/dev/net/tun:/dev/net/tun"];
        env_file = [config.age.secrets."common/tailscale/container.env".path];
        hostname = "${config.custom.hostname}-statping";
        image = "ghcr.io/tailscale/tailscale:v1.84.3"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/statping/vpn:/var/lib/tailscale"];

        capabilities = {
          NET_ADMIN = true;
        };
      };
    };
  };
}
