{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.syncthing;
  hm = config.home-manager.users.${config.custom.username};
in {
  # https://syncthing.net/
  # https://github.com/syncthing/syncthing
  # https://wiki.nixos.org/wiki/Syncthing
  options.custom.services.syncthing = {
    enable = mkEnableOption "syncthing";

    devices = mkOption {
      default = [
        "myosh"
        "mynix"
        "myork"
      ];

      description = "List of devices to sync";
      example = ["machine1" "machine2"];
      type = with types; listOf str;
    };

    # https://docs.syncthing.net/users/ignoring.html
    ignores = mkOption {
      default = [
        # Linux
        "(?d)*.kate-swp"
        "(?d).directory"
        "(?d).~*"

        # macOS
        "(?d).DS_Store"
        "(?d).Spotlight-V100"
        "(?d).Trashes"
        "(?d)__MACOSX"

        # Windows
        "(?d)*.laccdb"
        "(?d)~*"

        # Development
        "(?d)*.lock"
        "(?d)*.meldcmp"
        "(?d).data"
        "(?d).direnv"
        "(?d).venv"
        "(?d)node_modules"
      ];

      description = "List of ignores to add to each sync folder";
      example = ["(?d).~*"];
      type = with types; listOf str;
    };

    mount = mkOption {
      default = null;
      description = "Name of the systemd-mount to bind to the service";
      example = "mnt-local.mount";
      type = with types; nullOr str;
    };

    path = mkOption {
      default = hm.home.homeDirectory;
      description = "Path to root directory of sync folder";
      example = "/mnt/local/syncthing";
      type = types.path;
    };

    type = mkOption {
      default = "sendreceive";
      description = "Method in which to sync folders by default";
      example = "receiveonly";
      type = types.enum ["sendreceive" "sendonly" "receiveonly" "receiveencrypted"];
    };

    versioning = mkOption {
      default = {
        type = "trashcan";
        params.cleanoutDays = "7";
      };

      description = "Method in which to version modified files";

      example = {
        type = "simple";
        params.keep = "10";
      };

      type = types.attrs;
    };

    folders = mkOption {
      default = let
        folder = id: devices: {inherit id devices;};
      in {
        "SYNC/.backup" = folder "oxdvq-dfzjk" [];
        "SYNC/admin" = folder "l6odm-rmjep" [];
        "SYNC/android" = folder "y3omj-gpjch" ["myxel"];
        "SYNC/android/media/camera" = folder "udj03-5kwod" ["myxel"];
        "SYNC/common" = folder "fcsij-g7cnw" ["myeck" "myxel"];
        "SYNC/dev" = folder "fsmar-4wsd3" ["myxel"];
        "SYNC/edu" = folder "4nyqw-jfkq2" ["myxel"];
        "SYNC/game" = folder "xvdpp-mxlki" ["myeck" "zendows"];
        "SYNC/linux" = folder "ieikk-bnm7u" ["myxel"];
        "SYNC/mac" = folder "yjmt6-z7u4m" [];
        "SYNC/owo" = folder "ervqc-ebnzz" ["myxel"];
        "SYNC/windows" = folder "2hmna-vfap9" [];
        "ZEL/android" = folder "gn2l3-2hxtu" ["zendows" "zexel"] // {type = "receiveonly";};
        "ZEL/music" = folder "nytcx-uwqs7" ["zendows" "zexel"] // {type = "receiveonly";};
      };

      description = "Folders to sync by default";

      example = {
        Sync = {
          id = "abcde-fghij";
          devices = ["machine1" "machine2"];
        };
      };

      type = types.attrs;
    };
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        services.syncthing = {
          enable = true;
          guiAddress = "${config.custom.services.tailscale.ipv4}:8384";
          passwordFile = config.age.secrets."common/syncthing/${config.custom.username}.pass".path;

          # Syncthing no longer creates a default folder >= 2.0
          # https://github.com/syncthing/syncthing/releases/tag/v2.0.0
          extraOptions = optionals (versionOlder hm.services.syncthing.package.version "2") ["--no-default-folder"]; # Disable default Sync folder

          settings = {
            # https://docs.syncthing.net/users/config.html
            options = {
              localAnnounceEnabled = true; # 21027/udp
              globalAnnounceEnabled = false; # Global discovery allows device spoofing
              relaysEnabled = false;
              urAccepted = 1; # Usage report enabled
              urSeen = 3; # Usage report version
            };

            # https://docs.syncthing.net/rest/config.html
            # Undocumented endpoints can be manually extended starting from /rest/config/*
            #?? "defaults/ignores" = {lines = [];};
            gui.user = config.custom.username;

            # BUG: Defaults are not applied via API
            # https://github.com/syncthing/syncthing/issues/6748
            # https://github.com/NixOS/nixpkgs/issues/268282
            #// "defaults/ignores".lines = [];

            # Devices can be globally declared without issue
            # Syncthing seems to ignore entries that match the current machine's id
            devices = mapAttrs (name: value:
              {
                addresses = [
                  "dynamic"
                  "tcp://${name}:22000" # Add tailscale machines to static discovery
                ];
              }
              // value) {
              myosh = {
                introducer = true;
                id = "PTZV7ID-UYR37CU-GNRWHF3-JI3OVQ4-4YT7T4V-HB735JT-YIC5GLB-NPY36Q4";
              };

              myeck.id = "77DCMIH-2O6C4TK-3VK5S27-GZ5IXXB-CTSZ3YG-LMPHZTT-L55WAPZ-SLX4LAI";
              mynix.id = "4VBPQMB-L2UIAQA-7IVLQUH-GXMY624-OECCFXN-JMCZI44-Q6MADRJ-4VPV6QK";
              myork.id = "L7CAFJP-NXNEZUY-V36HDXP-V6T5CHP-2YCYV3P-JCQV6ZH-JEDULBU-BABJLQP";
              myxel.id = "JBNXW4H-WYAKVYR-7IGYUCP-4AAMX2F-EPE2NNH-PVN4CL7-P2Z2D6T-HC7JQAC";
              zendows.id = "4JS6YSF-OBZFPYW-B3OUF4G-R6DVOZ4-KFAVGFY-NT4J223-E44HK3D-GPYAFQP";
              zexel.id = "VYG4QAC-SY7ET5F-CHIPQUN-TP6P7WN-LQCT3HO-UBS73JG-ZGOKCLG-SHWZOAN";
            };

            # Boilerplate folder settings
            folders =
              mapAttrs (
                name: value:
                  {
                    path = "${cfg.path}/${name}";
                    type = cfg.type;
                    versioning = cfg.versioning;
                  }
                  // value
                  // {devices = cfg.devices ++ value.devices or [];}
              )
              cfg.folders;
          };
        };

        systemd.user = {
          #!! Syncthing needs to start after mounting or there is a risk of file deletion
          # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/syncthing.nix#L646
          #?? systemctl status
          services.syncthing = mkIf (!isNull cfg.mount) {
            Service = {
              After = [cfg.mount];
              BindsTo = [cfg.mount]; # Start/stop service on mount/unmount
            };
          };

          tmpfiles.rules = let
            stignores = pkgs.writeText "stignores" (concatStringsSep "\n" cfg.ignores);
          in
            forEach (attrNames cfg.folders) (folder: "L+ ${cfg.path}/${folder}/.stignore - - - - ${stignores}");
        };
      }
    ];

    age.secrets = listToAttrs (map (name: {
        inherit name;

        value = {
          file = "${inputs.self}/secrets/${name}";
          owner = config.custom.username;
          group = config.users.users.${config.custom.username}.group;
        };
      })
      [
        "common/syncthing/${config.custom.username}.pass"
      ]);
  };
}
