{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.containers.site;
  containerCfg = config.containers.site;
  hostCfg = config;
in {
  options.custom.containers.site = {
    enable = mkEnableOption "site";

    host = mkOption {
      description = "Host in which to bind";
      default = "::";
      example = "localhost";
      type = types.str;
    };

    port = mkOption {
      description = "Port in which to bind";
      default = 80;
      example = 4321;
      type = types.int;
    };
  };

  config = mkIf cfg.enable {
    containers.site = {
      agenix.secrets = ["${hostCfg.custom.hostname}/site/.env"];

      config = {
        # https://git.bjork.tech/myned/site
        systemd.services.site = {
          description = "Personal website, built with Astro and served by Node.js";
          wantedBy = ["default.target"];
          wants = ["network.target"];
          after = ["network.target"];

          environment = {
            NODE_ENV = "production";
            HOST = cfg.host;
            PORT = toString cfg.port;
          };

          serviceConfig = {
            Type = "notify";
            EnvironmentFile = hostCfg.age.secrets."${hostCfg.custom.hostname}/site/.env".path;
            WorkingDirectory = toString inputs.site.packages.${pkgs.system}.default;
            ExecStart = getExe inputs.site.packages.${pkgs.system}.default;
            Restart = "on-failure";

            # https://wiki.nixos.org/wiki/Systemd/Hardening
            # https://wiki.archlinux.org/title/Systemd/Sandboxing
            AmbientCapabilities = "CAP_NET_BIND_SERVICE";
            CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
            LockPersonality = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateTmp = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            ProtectSystem = "full";
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
          };
        };
      };
    };
  };
}
