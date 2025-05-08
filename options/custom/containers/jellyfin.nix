{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.jellyfin;
in {
  options.custom.containers.jellyfin = {
    enable = mkEnableOption "jellyfin";
  };

  config = mkIf cfg.enable {
    #?? arion-jellyfin pull
    environment.shellAliases.arion-jellyfin = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.jellyfin.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.jellyfin.settings.services = {
      # https://jellyfin.org/
      # https://jellyfin.org/docs/general/installation/container
      # https://github.com/jellyfin/jellyfin
      # https://github.com/Morzomb/All-jellyfin-media-server
      jellyfin.service = {
        container_name = "jellyfin";
        image = "ghcr.io/jellyfin/jellyfin:2025050505"; # https://github.com/jellyfin/jellyfin/pkgs/container/jellyfin
        ports = ["8096:8096/tcp"];
        restart = "unless-stopped";
        user = "1001:1001";

        volumes = [
          "${config.custom.containers.directory}/jellyfin/cache:/cache"
          "${config.custom.containers.directory}/jellyfin/config:/config"
          "${config.custom.containers.directory}/jellyfin/data:/data"
        ];
      };

      # BUG: Permission denied: '/.local'
      # https://github.com/FlareSolverr/FlareSolverr/issues/1430
      # https://github.com/FlareSolverr/FlareSolverr
      # flaresolverr.service = {
      #   container_name = "jellyfin-flaresolverr";
      #   image = "ghcr.io/flaresolverr/flaresolverr:latest"; # https://github.com/FlareSolverr/FlareSolverr/pkgs/container/flaresolverr
      #   ports = ["8191:8191/tcp"];
      #   restart = "unless-stopped";
      #   user = "1001:1001";
      # };

      # https://github.com/Jackett/Jackett
      jackett.service = {
        container_name = "jellyfin-jackett";
        image = "ghcr.io/linuxserver/jackett:latest"; # https://github.com/linuxserver/docker-jackett/pkgs/container/jackett
        ports = ["9117:9117/tcp"];
        restart = "unless-stopped";

        volumes = [
          "${config.custom.containers.directory}/jellyfin/jackett:/config"
          "${config.custom.containers.directory}/jellyfin/blackhole:/downloads"
        ];

        environment = {
          PUID = "1001";
          PGID = "1001";
        };
      };

      # https://docs.jellyseerr.dev/
      # https://github.com/Fallenbagel/jellyseerr
      jellyseerr.service = {
        container_name = "jellyfin-jellyseerr";
        image = "ghcr.io/fallenbagel/jellyseerr:latest"; # https://github.com/fallenbagel/jellyseerr/pkgs/container/jellyseerr
        ports = ["5055:5055/tcp"];
        restart = "unless-stopped";
        user = "1001:1001";
        volumes = ["${config.custom.containers.directory}/jellyfin/jellyseerr:/app/config"];
      };

      # https://prowlarr.com/
      # https://github.com/Prowlarr/Prowlarr
      prowlarr.service = {
        container_name = "jellyfin-prowlarr";
        image = "ghcr.io/linuxserver/prowlarr:latest"; # https://github.com/linuxserver/docker-prowlarr/pkgs/container/prowlarr
        ports = ["9696:9696/tcp"];
        restart = "unless-stopped";
        volumes = ["${config.custom.containers.directory}/jellyfin/prowlarr:/config"];

        environment = {
          PUID = "1001";
          PGID = "1001";
        };
      };

      # https://www.qbittorrent.org/
      # https://github.com/linuxserver/docker-qbittorrent
      qbittorrent.service = {
        container_name = "jellyfin-qbittorrent";
        image = "ghcr.io/linuxserver/qbittorrent:latest"; # https://github.com/linuxserver/docker-qbittorrent/pkgs/container/qbittorrent
        restart = "unless-stopped";

        ports = [
          "8881:8881/tcp"
          #// "6881:6881/tcp"
          #// "6881:6881/udp"
        ];

        volumes = [
          "${config.custom.containers.directory}/jellyfin/qbittorrent:/config"
          "${config.custom.containers.directory}/jellyfin/data:/data"
        ];

        environment = {
          PUID = "1001";
          PGID = "1001";
          WEBUI_PORT = 8881;
        };
      };

      # https://radarr.video/
      # https://github.com/Radarr/Radarr
      radarr.service = {
        container_name = "jellyfin-radarr";
        image = "ghcr.io/linuxserver/radarr:latest"; # https://github.com/linuxserver/docker-radarr/pkgs/container/radarr
        ports = ["7878:7878/tcp"];
        restart = "unless-stopped";

        volumes = [
          "${config.custom.containers.directory}/jellyfin/radarr:/config"
          "${config.custom.containers.directory}/jellyfin/data:/data"
        ];

        environment = {
          PUID = "1001";
          PGID = "1001";
        };
      };

      # https://sonarr.tv/
      # https://github.com/Sonarr/Sonarr
      sonarr.service = {
        container_name = "jellyfin-sonarr";
        image = "ghcr.io/linuxserver/sonarr:latest"; # https://github.com/linuxserver/docker-sonarr/pkgs/container/sonarr
        ports = ["8989:8989/tcp"];
        restart = "unless-stopped";

        volumes = [
          "${config.custom.containers.directory}/jellyfin/sonarr:/config"
          "${config.custom.containers.directory}/jellyfin/data:/data"
        ];

        environment = {
          PUID = "1001";
          PGID = "1001";
        };
      };
    };

    #?? arion-jellyfin run -- --rm --entrypoint=id jellyfin
    systemd.tmpfiles.settings.jellyfin = let
      owner = mode: {
        inherit mode;
        user = "1001";
        group = "1001";
      };
    in {
      "${config.custom.containers.directory}/jellyfin/blackhole" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/jellyfin/cache" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/jellyfin/config" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/jellyfin/data" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/jellyfin/data/downloads" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/jellyfin/data/movies" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/jellyfin/data/music" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/jellyfin/data/shows" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/jellyfin/jackett" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/jellyfin/jellyseerr" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/jellyfin/prowlarr" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/jellyfin/qbittorrent" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/jellyfin/radarr" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };

      "${config.custom.containers.directory}/jellyfin/sonarr" = {
        d = owner "0700"; # -rwx------
        z = owner "0700"; # -rwx------
      };
    };
  };
}
