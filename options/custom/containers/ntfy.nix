{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.ntfy;
in {
  options.custom.containers.ntfy = {
    enable = mkEnableOption "ntfy";
  };

  config = mkIf cfg.enable {
    #?? arion-ntfy pull
    environment.shellAliases.arion-ntfy = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.ntfy.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.ntfy.settings.services = {
      # https://ntfy.sh/
      # https://github.com/binwiederhier/ntfy
      ntfy.service = {
        command = "serve";
        container_name = "ntfy";
        image = "binwiederhier/ntfy:v2.13.0"; # https://hub.docker.com/r/binwiederhier/ntfy/tags
        ports = ["2586:80/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/ntfy/db:/var/lib/ntfy"];

        # https://docs.ntfy.sh/config/
        # https://docs.ntfy.sh/config/#behind-a-proxy-tls-etc
        # https://github.com/binwiederhier/ntfy/blob/main/server/server.yml
        #?? arion-ntfy exec ntfy ntfy -- user add --role=admin <username>
        environment = {
          NTFY_ATTACHMENT_CACHE_DIR = "/var/lib/ntfy/attachments";
          NTFY_AUTH_DEFAULT_ACCESS = "read-write"; # https://docs.ntfy.sh/config/#example-unifiedpush
          NTFY_AUTH_FILE = "/var/lib/ntfy/auth.db";
          NTFY_BASE_URL = "https://notify.vpn.${config.custom.domain}";
          NTFY_BEHIND_PROXY = "true";
          NTFY_CACHE_DURATION = "7d";
          NTFY_CACHE_FILE = "/var/lib/ntfy/cache.db";
          NTFY_ENABLE_LOGIN = "true";
          NTFY_LOG_LEVEL = "INFO";
        };
      };
    };
  };
}
