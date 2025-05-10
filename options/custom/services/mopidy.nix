{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.mopidy;

  upmpdcli = getExe pkgs.upmpdcli;
in {
  options.custom.services.mopidy = {
    enable = mkEnableOption "mopidy";

    rygel = {
      enable = mkOption {
        default = false;
        type = types.bool;
      };

      interface = mkOption {
        default =
          if config.custom.services.tailscale.enable
          then "tailscale0"
          else "";

        type = types.str;
      };

      port = mkOption {
        default = 1900;
        type = types.int;
      };

      extraConfig = mkOption {
        default = generators.toINI {} {
          general = {
            interface = cfg.rygel.interface;
            port = cfg.rygel.port;
          };

          Tracker3.enabled = false; # Default: true
          Tracker.enabled = false; # Default: true
          MediaExport.enabled = false; # Default: true
          MPRIS.enabled = true; # Default: false
          Playbin.title = "@PRETTY_HOSTNAME@"; # Default: Audio/Video playback on @PRETTY_HOSTNAME@
        };

        type = types.str;
      };
    };

    upmpdcli = {
      enable = mkOption {
        default = true;
        type = types.bool;
      };

      interface = mkOption {
        default =
          if config.custom.services.tailscale.enable
          then "tailscale0"
          else "";

        type = types.str;
      };

      port = mkOption {
        default = 1900;
        type = types.int;
      };

      extraConfig = mkOption {
        default = generators.toINIWithGlobalSection {} {
          globalSection = {
            upnpiface = cfg.rygel.interface;
            upnpport = cfg.rygel.port;
            useipv6 = true;
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
        owner = config.custom.username;
        group = config.users.users.${config.custom.username}.group;
      };
    in {
      "common/mopidy/mopidy.conf" = secret "common/mopidy/mopidy.conf";
    };

    # https://wiki.archlinux.org/title/Rygel
    # https://wiki.gnome.org/Projects/Rygel
    # https://gitlab.gnome.org/GNOME/rygel
    services.gnome.rygel.enable = cfg.rygel.enable;

    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/desktops/gnome/rygel.nix
    # https://gitlab.gnome.org/GNOME/rygel/-/blob/master/data/rygel.conf
    environment.etc =
      optionalAttrs cfg.rygel.enable {
        "rygel.conf" = mkForce {
          text = ''
            ${builtins.readFile "${pkgs.rygel}/etc/rygel.conf"}
            ${cfg.rygel.extraConfig}
          '';
        };
      }
      // optionalAttrs cfg.upmpdcli.enable {
        # https://framagit.org/medoc92/upmpdcli/-/blob/master/src/upmpdcli.conf-dist
        "upmpdcli.conf" = {
          text = ''
            ${builtins.readFile "${inputs.upmpdcli}/src/upmpdcli.conf-dist"}
            ${cfg.upmpdcli.extraConfig}
          '';
        };
      };

    networking.firewall = mkIf cfg.rygel.enable {
      allowedTCPPorts = [cfg.rygel.port];
      allowedUDPPorts = [cfg.rygel.port];
    };

    home-manager.sharedModules = [
      {
        # https://wiki.nixos.org/wiki/Mopidy
        # https://docs.mopidy.com/stable/
        # https://github.com/mopidy/mopidy
        services.mopidy = {
          enable = true;
          extraConfigFiles = [config.age.secrets."common/mopidy/mopidy.conf".path];

          extensionPackages = with pkgs;
            [
              mopidy-jellyfin
              #// mopidy-notify
              #// mopidy-scrobbler
            ]
            ++ optionals cfg.upmpdcli.enable [
              # https://docs.mopidy.com/latest/upnp/#mopidy-mpd-and-upmpdcli
              mopidy-mpd
            ]
            ++ optionals cfg.rygel.enable [
              mopidy-mpris
            ];

          # https://docs.mopidy.com/stable/config/
          settings = {
          };
        };

        # https://framagit.org/medoc92/upmpdcli/-/blob/master/systemd/upmpdcli.service
        systemd.user.services.upmpdcli = mkIf cfg.upmpdcli.enable {
          Unit = {
            Description = "UPnP Renderer front-end to MPD";
            After = ["network-online.target" "mpd.service"];
            Wants = ["network-online.target"];
          };

          Service = {
            Type = "simple";
            ExecStart = "${upmpdcli} -c /etc/upmpdcli.conf";
            Restart = "always";
            RestartSec = "1min";
          };

          Install = {
            WantedBy = ["multi-user.target"];
          };
        };
      }
    ];
  };
}
