{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.opengist;
in {
  options.custom.containers.opengist = {
    enable = mkEnableOption "opengist";
  };

  config = mkIf cfg.enable {
    #?? arion-opengist pull
    environment.shellAliases.arion-opengist = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.opengist.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.opengist.settings.services = {
      # https://opengist.io/
      # https://opengist.io/docs/installation/docker.html
      # https://github.com/thomiceli/opengist
      opengist.service = {
        container_name = "opengist";
        depends_on = ["vpn"];
        image = "ghcr.io/thomiceli/opengist:1"; # https://github.com/thomiceli/opengist/pkgs/container/opengist
        network_mode = "service:vpn"; # 6157/tcp
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/opengist/data:/opengist"];

        # https://opengist.io/docs/configuration/cheat-sheet.html
        environment = {
          OG_EXTERNAL_URL = "https://gist.${config.custom.domain}";
          OG_GIT_DEFAULT_BRANCH = "master";
          OG_LOG_LEVEL = "info";
          OG_LOG_OUTPUT = "stdout";
          OG_SSH_EXTERNAL_DOMAIN = "${config.custom.hostname}-opengist";
          OG_SSH_PORT = 22;
          UID = 1001;
          GID = 1001;
        };
      };

      # https://tailscale.com/kb/1282/docker
      vpn.service = {
        container_name = "opengist-vpn";
        devices = ["/dev/net/tun:/dev/net/tun"];
        env_file = [config.age.secrets."common/tailscale/container.env".path];
        hostname = "${config.custom.hostname}-opengist";
        image = "ghcr.io/tailscale/tailscale:latest"; # https://github.com/tailscale/tailscale/pkgs/container/tailscale
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/opengist/vpn:/var/lib/tailscale"];

        capabilities = {
          NET_ADMIN = true;
        };
      };
    };

    #?? arion-opengist run -- --rm --entrypoint=id opengist
    systemd.tmpfiles.settings.opengist = let
      owner = mode: {
        inherit mode;
        user = "1001";
        group = "1001";
      };
    in {
      "${config.custom.containers.directory}/opengist/data" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };
    };
  };
}
