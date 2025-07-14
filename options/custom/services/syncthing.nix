{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.syncthing;
in {
  # https://github.com/syncthing/syncthing
  # https://wiki.nixos.org/wiki/Syncthing
  # https://docs.syncthing.net/users/config.html
  options.custom.services.syncthing = {
    enable = mkEnableOption "syncthing";

    configDir = mkOption {
      default = "${cfg.dataDir}/.config/syncthing";
      type = types.path;
    };

    dataDir = mkOption {
      default = "/home/${cfg.user}";
      type = types.path;
    };

    devices = mkOption {
      default = [
        "myosh" # Introducer
        "mynix"
        "myork"
      ];

      type = with types; listOf str;
    };

    ignorePerms = mkOption {
      default = false;
      type = types.bool;
    };

    # https://docs.syncthing.net/users/ignoring.html
    ignores = mkOption {
      default = ''
        // Linux
        (?d)*.kate-swp
        (?d).directory
        (?d).~*

        // macOS
        (?d).DS_Store
        (?d).Spotlight-V100
        (?d).Trashes
        (?d)__MACOSX

        // Windows
        (?d)*.laccdb
        (?d)~*

        // Development
        (?d)*.lock
        (?d)*.meldcmp
        (?d).data
        (?d).direnv
        (?d).venv
        (?d)node_modules
      '';

      type = types.str;
    };

    # systemd mount to bind to
    #?? mnt-local.mount
    mount = mkOption {
      default = null;
      type = with types; nullOr str;
    };

    order = mkOption {
      default = "alphabetic";
      type = types.str;
    };

    type = mkOption {
      default = "sendreceive";
      type = types.str;
    };

    user = mkOption {
      default = config.custom.username;
      type = types.str;
    };

    group = mkOption {
      default = config.users.users.${config.custom.username}.group;
      type = types.str;
    };

    # https://docs.syncthing.net/users/versioning.html
    versioning = mkOption {
      default = {
        params.cleanoutDays = "7";
        type = "trashcan";
      };

      type = types.attrs;
    };

    # https://docs.syncthing.net/users/foldertypes.html
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
    };
  };

  config = mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      configDir = cfg.configDir;
      dataDir = cfg.dataDir;
      extraFlags = ["-no-default-folder"]; # Disable automatic creation of Sync folder
      guiAddress = "${config.custom.services.tailscale.ip}:8384";
      openDefaultPorts = true; # Transfer/discovery ports
      user = cfg.user;
      group = cfg.group;

      # https://docs.syncthing.net/rest/config.html
      # Undocumented endpoints can be manually extended onto /rest/config/*
      #?? "END/POINT" = null
      #!! Untrusted devices/folders are not exposed via options
      # https://github.com/NixOS/nixpkgs/issues/121286
      #!! GUI configured imperatively
      settings = {
        options.urAccepted = 1; # Usage statistics

        # BUG: Defaults are not applied via API
        # https://github.com/syncthing/syncthing/issues/6748
        # https://github.com/NixOS/nixpkgs/issues/268282
        #// "defaults/ignores".lines = [];

        # Devices can be declared globally without issue
        # Syncthing seems to ignore entries that match the machine's id
        devices = {
          myosh = {
            introducer = true;
            id = "H6UYGJ6-ST2BKYH-5A45PSN-XEKYCSW-XXTE6CK-7PHKSDF-7AK6OZC-KRWNFAO";
          };

          mynix.id = "UFLECA5-QQUKD5J-FQB55TE-YKKHD37-VT5ASXU-4EGUZNV-KW7Z434-FBI7CQ2";
          myork.id = "AZZZVMU-G2WA5T7-CAAAULE-2N6SVJL-RWN6RIE-THJRG6Y-QRDZ2LP-56K7BQ2";
          myxel.id = "6ER5UMP-KVYYKVY-AL5NAC6-W4KRXTB-UYRQG4R-AFWK66C-RWOULMW-EATTVQV";
          myeck.id = "NLGUPGG-XFGRDSE-43MQEXO-TLEW2XD-DMOL6RM-RPQ4IFQ-GENDXPF-PM7NQAO";
          zendows.id = "4JS6YSF-OBZFPYW-B3OUF4G-R6DVOZ4-KFAVGFY-NT4J223-E44HK3D-GPYAFQP";
          zexel.id = "VYG4QAC-SY7ET5F-CHIPQUN-TP6P7WN-LQCT3HO-UBS73JG-ZGOKCLG-SHWZOAN";
        };

        # Boilerplate folder settings
        folders =
          concatMapAttrs (name: folder: {
            "~/${name}" =
              {
                ignorePerms = cfg.ignorePerms;
                label = name;
                order = cfg.order;
                type = cfg.type;
                versioning = cfg.versioning;
              }
              // folder
              // {devices = cfg.devices ++ folder.devices or [];};
          })
          cfg.folders;
      };
    };

    systemd = {
      tmpfiles.settings.syncthing = let
        owner = mode: {
          inherit mode;
          user = cfg.user;
          group = cfg.group;
        };
      in
        {
          # Ensure creation of config directory
          ${cfg.configDir} = {
            d = owner "0700"; # -rwx------
            z = owner "0700"; # -rwx------
          };
        }
        # HACK: Manually create .stignore files in lieu of option
        # https://github.com/NixOS/nixpkgs/pull/353770
        // concatMapAttrs (folder: _: {
          "${cfg.dataDir}/${folder}/.stignore" = {
            "f+" = owner "0400" // {argument = cfg.ignores;}; # -r--------
            z = owner "0400"; # -r--------
          };
        })
        cfg.folders;

      #!! Syncthing needs to start after mounting or there is a risk of file deletion
      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/syncthing.nix#L646
      #?? systemctl status
      services.syncthing = {
        after = optionals (isString cfg.mount) [cfg.mount];
        bindsTo = optionals (isString cfg.mount) [cfg.mount]; # Start/stop service on mount/unmount
        requires = optionals config.custom.services.tailscale.enable ["tailscaled.service"];
      };
    };
  };
}
