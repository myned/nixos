{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.containers.netdata;
in {
  options.custom.containers.netdata = {
    enable = mkEnableOption "netdata";

    role = mkOption {
      default = null;
      type = with types; nullOr (enum ["child" "parent"]);
    };

    # https://learn.netdata.cloud/docs/netdata-agent/configuration/
    #?? curl localhost:19999/netdata.conf -o ./config/netdata.example.conf
    settings = mkOption {
      default = null;
      type = with types; nullOr (attrsOf attrs);
    };
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in
      optionalAttrs (!isNull cfg.role) {
        "${config.custom.profile}/netdata/${cfg.role}.conf" = secret "${config.custom.profile}/netdata/${cfg.role}.conf";
      };

    #?? arion-netdata pull
    environment.shellAliases.arion-netdata = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.netdata.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.netdata.settings = {
      services = {
        # https://www.netdata.cloud/
        # https://github.com/netdata/netdata
        # https://learn.netdata.cloud/docs/netdata-agent/installation/docker
        netdata.service = {
          container_name = "netdata";
          image = "ghcr.io/netdata/netdata:v2"; # https://github.com/netdata/netdata/pkgs/container/netdata
          network_mode = "host";
          privileged = true;
          restart = "unless-stopped";

          volumes =
            [
              "${config.custom.containers.directory}/netdata/config:/etc/netdata"
              "${config.custom.containers.directory}/netdata/data:/var/lib/netdata"
              "/:/host/root:ro,rslave"
              "/etc/group:/host/etc/group:ro"
              "/etc/localtime:/etc/localtime:ro"
              "/etc/os-release:/host/etc/os-release:ro"
              "/etc/passwd:/host/etc/passwd:ro"
              "/proc:/host/proc:ro"
              "/run/dbus:/run/dbus:ro"
              "/sys:/host/sys:ro"
              "/var/log:/host/var/log:ro"
              "/var/run/docker.sock:/var/run/docker.sock:ro"
            ]
            ++ optionals (!isNull cfg.role) [
              "${config.age.secrets."${config.custom.profile}/netdata/${cfg.role}.conf".path}:/etc/netdata/stream.conf:ro"
            ]
            ++ optionals (!isNull cfg.settings) [
              "${pkgs.writeText "netdata.conf" (generators.toINI {} cfg.settings)}:/etc/netdata/netdata.conf:ro"
            ];
        };
      };

      # FIXME: Raw attr not taking effect
      #?? arion-netdata cat
      # HACK: pid not currently supported
      # https://github.com/hercules-ci/arion/issues/261
      docker-compose.raw = {
        services.netdata = {
          pid = "host";
        };
      };
    };
  };
}
