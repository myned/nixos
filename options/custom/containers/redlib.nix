{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.redlib;
in {
  options.custom.containers.redlib.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    #?? arion-redlib pull
    environment.shellAliases.arion-redlib = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.redlib.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.redlib.settings.services = {
      # https://github.com/redlib-org/redlib
      redlib.service = {
        container_name = "redlib";
        image = "quay.io/redlib/redlib:latest";
        ports = ["127.0.0.1:8888:8080/tcp"];
        restart = "unless-stopped";

        environment = {
          REDLIB_DEFAULT_HIDE_HLS_NOTIFICATION = "on";
          REDLIB_DEFAULT_SHOW_NSFW = "on";
          REDLIB_DEFAULT_THEME = "dracula";
          REDLIB_DEFAULT_USE_HLS = "on";
          REDLIB_DEFAULT_WIDE = "off";
        };
      };
    };
  };
}
