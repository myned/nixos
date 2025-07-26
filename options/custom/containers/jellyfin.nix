{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.jellyfin;
in {
  options.custom.containers.jellyfin = {
    enable = mkEnableOption "jellyfin";

    dataDir = mkOption {
      default = "${config.custom.containers.directory}/jellyfin/data";
      type = types.str;
    };

    uid = mkOption {
      default = "1000";
      type = types.str;
    };

    gid = mkOption {
      default = "1000";
      type = types.str;
    };

    vue = mkOption {
      default = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    #?? arion-jellyfin pull
    environment.shellAliases.arion-jellyfin = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.jellyfin.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects = {
      jellyfin.settings.services =
        {
          # https://jellyfin.org/
          # https://jellyfin.org/docs/general/installation/container
          # https://github.com/jellyfin/jellyfin
          # https://github.com/Morzomb/All-jellyfin-media-server
          jellyfin.service = {
            container_name = "jellyfin";
            image = "ghcr.io/jellyfin/jellyfin:10.10.7"; # https://github.com/jellyfin/jellyfin/pkgs/container/jellyfin
            network_mode = "container:mullvad"; # 8096/tcp
            restart = "unless-stopped";
            user = "${cfg.uid}:${cfg.gid}";

            volumes = [
              "${config.custom.containers.directory}/jellyfin/cache:/cache"
              "${config.custom.containers.directory}/jellyfin/config:/config"
              "${cfg.dataDir}:/data"
            ];
          };

          # BUG: Permission denied: '/.local'
          # https://github.com/FlareSolverr/FlareSolverr/issues/1430
          # https://github.com/FlareSolverr/FlareSolverr
          # flaresolverr.service = {
          #   container_name = "jellyfin-flaresolverr";
          #   image = "ghcr.io/flaresolverr/flaresolverr:v3.3.25"; # https://github.com/FlareSolverr/FlareSolverr/pkgs/container/flaresolverr
          #   network_mode = "container:mullvad"; # 8191/tcp
          #   restart = "unless-stopped";
          #   user = "${cfg.uid}:${cfg.gid}";
          # };

          # https://docs.jellyseerr.dev/
          # https://github.com/Fallenbagel/jellyseerr
          jellyseerr.service = {
            container_name = "jellyfin-jellyseerr";
            image = "ghcr.io/fallenbagel/jellyseerr:2.7.2"; # https://github.com/fallenbagel/jellyseerr/pkgs/container/jellyseerr
            network_mode = "container:mullvad"; # 5055/tcp
            restart = "unless-stopped";
            user = "${cfg.uid}:${cfg.gid}";
            volumes = ["${config.custom.containers.directory}/jellyfin/jellyseerr:/app/config"];
          };

          # https://lidarr.audio/
          # https://github.com/Lidarr/Lidarr
          lidarr.service = {
            container_name = "jellyfin-lidarr";
            image = "ghcr.io/linuxserver/lidarr:2.12.4"; # https://github.com/linuxserver/docker-lidarr/pkgs/container/lidarr
            network_mode = "container:mullvad"; # 8686/tcp
            restart = "unless-stopped";

            volumes = [
              "${config.custom.containers.directory}/jellyfin/lidarr:/config"
              "${cfg.dataDir}:/data"
            ];

            environment = {
              PUID = cfg.uid;
              PGID = cfg.gid;
            };
          };

          # https://prowlarr.com/
          # https://github.com/Prowlarr/Prowlarr
          prowlarr.service = {
            container_name = "jellyfin-prowlarr";
            image = "ghcr.io/linuxserver/prowlarr:1.37.0"; # https://github.com/linuxserver/docker-prowlarr/pkgs/container/prowlarr
            network_mode = "container:mullvad"; # 9696/tcp
            restart = "unless-stopped";
            volumes = ["${config.custom.containers.directory}/jellyfin/prowlarr:/config"];

            environment = {
              PUID = cfg.uid;
              PGID = cfg.gid;
            };
          };

          # https://www.qbittorrent.org/
          # https://github.com/linuxserver/docker-qbittorrent
          qbittorrent.service = {
            container_name = "jellyfin-qbittorrent";
            image = "ghcr.io/linuxserver/qbittorrent:5.1.2"; # https://github.com/linuxserver/docker-qbittorrent/pkgs/container/qbittorrent
            network_mode = "container:mullvad"; # 8881/tcp
            restart = "unless-stopped";

            volumes = [
              "${config.custom.containers.directory}/jellyfin/qbittorrent:/config"
              "${cfg.dataDir}:/data"
            ];

            environment = {
              PUID = cfg.uid;
              PGID = cfg.gid;
              WEBUI_PORT = 8881;
            };
          };

          # https://radarr.video/
          # https://github.com/Radarr/Radarr
          radarr.service = {
            container_name = "jellyfin-radarr";
            image = "ghcr.io/linuxserver/radarr:5.26.2"; # https://github.com/linuxserver/docker-radarr/pkgs/container/radarr
            network_mode = "container:mullvad"; # 7878/tcp
            restart = "unless-stopped";

            volumes = [
              "${config.custom.containers.directory}/jellyfin/radarr:/config"
              "${cfg.dataDir}:/data"
            ];

            environment = {
              PUID = cfg.uid;
              PGID = cfg.gid;
            };
          };

          # https://github.com/slskd/slskd
          # https://github.com/slskd/slskd/blob/master/docs/docker.md
          slskd.service = {
            container_name = "jellyfin-slskd";
            env_file = [config.age.secrets."${config.custom.hostname}/jellyfin/slskd.env".path];
            image = "ghcr.io/slskd/slskd:0.23.1"; # https://github.com/slskd/slskd/pkgs/container/slskd
            network_mode = "container:mullvad"; # 5030/tcp 5031/tcp 50300/tcp
            restart = "unless-stopped";
            user = "${cfg.uid}:${cfg.gid}";

            volumes = [
              "${config.custom.containers.directory}/jellyfin/slskd:/app"
              "${cfg.dataDir}:/data"
            ];

            # https://github.com/slskd/slskd/blob/master/docs/config.md
            environment = {
              SLSKD_SHARED_DIR = "/data/music";
              SLSKD_DOWNLOADS_DIR = "/data/downloads/slskd/complete";
              SLSKD_INCOMPLETE_DIR = "/data/downloads/slskd/incomplete";
              SLSKD_UPLOAD_SLOTS = "5";
              SLSKD_UPLOAD_SPEED_LIMIT = "1000"; # KiB
              SLSKD_REMOTE_CONFIGURATION = "true";
            };
          };

          # https://sonarr.tv/
          # https://github.com/Sonarr/Sonarr
          sonarr.service = {
            container_name = "jellyfin-sonarr";
            image = "ghcr.io/linuxserver/sonarr:4.0.15"; # https://github.com/linuxserver/docker-sonarr/pkgs/container/sonarr
            network_mode = "container:mullvad"; # 8989/tcp
            restart = "unless-stopped";

            volumes = [
              "${config.custom.containers.directory}/jellyfin/sonarr:/config"
              "${cfg.dataDir}:/data"
            ];

            environment = {
              PUID = cfg.uid;
              PGID = cfg.gid;
            };
          };

          # https://soularr.net/
          # https://github.com/mrusse/soularr
          soularr.service = {
            container_name = "jellyfin-soularr";
            depends_on = ["lidarr" "slskd"];
            image = "mrusse08/soularr:latest"; # https://hub.docker.com/r/mrusse08/soularr/tags
            network_mode = "container:mullvad";
            restart = "unless-stopped";
            user = "${cfg.uid}:${cfg.gid}";

            volumes = [
              "${config.custom.containers.directory}/jellyfin/soularr:/data"
              "${cfg.dataDir}/downloads:/data/downloads"
              "${config.age.secrets."${config.custom.hostname}/jellyfin/soularr.ini".path}:/data/config.ini:ro"
            ];
          };
        }
        // optionalAttrs cfg.vue {
          # https://jellyfin.org/docs/general/clients/jellyfin-vue
          # https://github.com/jellyfin/jellyfin-vue
          vue.service = {
            container_name = "jellyfin-vue";
            depends_on = ["jellyfin"];
            image = "ghcr.io/jellyfin/jellyfin-vue:unstable"; # https://github.com/jellyfin/jellyfin-vue/pkgs/container/jellyfin-vue
            network_mode = "container:mullvad"; # 80/tcp
            restart = "unless-stopped";

            # https://github.com/jellyfin/jellyfin-vue/wiki/Configuration
            environment = {
              DEFAULT_SERVERS = "media.vpn.${config.custom.domain}";
              DISABLE_SERVER_SELECTION = "1";
            };
          };
        };

      mullvad.settings.services.mullvad.service.ports = [
        "5030:5030/tcp"
        "5055:5055/tcp"
        "7878:7878/tcp"
        "8096:8096/tcp"
        "8097:80/tcp"
        #// "8191:8191/tcp"
        "8686:8686/tcp"
        "8881:8881/tcp"
        "8989:8989/tcp"
        "9696:9696/tcp"
      ];
    };

    #?? arion-jellyfin run -- --rm --entrypoint=id jellyfin
    systemd.tmpfiles.settings.jellyfin = let
      owner = mode: {
        inherit mode;
        user = cfg.uid;
        group = cfg.gid;
      };
    in
      listToAttrs (map (name: {
          inherit name;
          value = {
            d = owner "0700"; # -rwx------
            z = owner "0700"; # -rwx------
          };
        }) [
          "${cfg.dataDir}"
          "${cfg.dataDir}/downloads"
          "${cfg.dataDir}/downloads/radarr"
          "${cfg.dataDir}/downloads/slskd"
          "${cfg.dataDir}/downloads/slskd/complete"
          "${cfg.dataDir}/downloads/slskd/incomplete"
          "${cfg.dataDir}/downloads/sonarr"
          "${cfg.dataDir}/movies"
          "${cfg.dataDir}/music"
          "${cfg.dataDir}/shows"
          "${config.custom.containers.directory}/jellyfin/blackhole"
          "${config.custom.containers.directory}/jellyfin/cache"
          "${config.custom.containers.directory}/jellyfin/config"
          "${config.custom.containers.directory}/jellyfin/jellyseerr"
          "${config.custom.containers.directory}/jellyfin/lidarr"
          "${config.custom.containers.directory}/jellyfin/prowlarr"
          "${config.custom.containers.directory}/jellyfin/qbittorrent"
          "${config.custom.containers.directory}/jellyfin/radarr"
          "${config.custom.containers.directory}/jellyfin/slskd"
          "${config.custom.containers.directory}/jellyfin/sonarr"
        ]);

    age.secrets = listToAttrs (map (name: {
        inherit name;

        value = {
          file = "${inputs.self}/secrets/${name}";
          owner = cfg.uid;
          group = cfg.gid;
        };
      })
      [
        "${config.custom.hostname}/jellyfin/slskd.env"
        "${config.custom.hostname}/jellyfin/soularr.ini"
      ]);
  };
}
