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
    enable = mkOption {default = false;};
    configDir = mkOption {default = "${cfg.dataDir}/.config/syncthing";};
    dataDir = mkOption {default = "/home/${cfg.user}";};
    devices = mkOption {
      default = [
        "myne"
        "mynix"
        "myork"
      ];
    };
    ignorePerms = mkOption {default = false;};
    mount = mkOption {default = null;};
    order = mkOption {default = "alphabetic";};
    type = mkOption {default = "sendreceive";};
    user = mkOption {default = config.custom.username;};
    group = mkOption {default = "users";};

    # TODO: Use staggered versioning
    versioning = mkOption {
      default = {
        params.cleanoutDays = "7";
        type = "trashcan";
      };
    };

    # Per folder attributes override config
    folders = mkOption {
      default = let
        #?? "FOLDER" = folder "ID" [ "DEVICES" ]
        folder = id: devices: {inherit id devices;};
      in {
        "SYNC/.backup" = folder "oxdvq-dfzjk" [];
        "SYNC/.ignore" = folder "qpvfw-j127s" ["myeck" "myxel"];
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
      #// guiAddress = "0.0.0.0:8384"; # Open to all interfaces
      openDefaultPorts = true; # Open transfer/discovery ports
      user = cfg.user;
      group = cfg.group;

      # https://docs.syncthing.net/rest/config.html
      # Undocumented endpoints can be manually extended onto /rest/config/*
      #?? "END/POINT" = null
      #!! Untrusted devices/folders are not exposed via options
      # https://github.com/NixOS/nixpkgs/issues/121286
      #!! GUI configured imperatively
      settings = {
        options.urAccepted = -1; # Decline usage statistics

        # BUG: Defaults are not applied via API
        # https://github.com/syncthing/syncthing/issues/6748
        # https://github.com/NixOS/nixpkgs/issues/268282
        "defaults/ignores".lines = [
          # Linux
          "(?d).~*"
          "(?d).directory"
          "(?d)*.kate-swp"

          # macOS
          "(?d).DS_Store"
          "(?d).Spotlight-V100"
          "(?d).Trashes"
          "(?d)__MACOSX"

          # Windows
          "(?d)~*"
          "(?d)*.laccdb"

          # Development
          "(?d).venv"
          "(?d).data"
          "(?d)*.lock"
          "(?d)*.meldcmp"
          "(?d)node_modules"
        ];

        # Devices can be declared globally without issue
        # Syncthing seems to ignore entries that match the machine's id
        devices = {
          myne = {
            introducer = true;
            id = "3YFGJ2J-X2653BB-WHKO54B-7FSL4LH-4CP4AUX-ZSUNIXW-NOBWBAN-324UOQR";
          };

          mynix.id = "UFLECA5-QQUKD5J-FQB55TE-YKKHD37-VT5ASXU-4EGUZNV-KW7Z434-FBI7CQ2";
          myork.id = "UTVTIWY-6YCR2XG-UPCUFDX-O6AVZQP-XJM7ZA6-CPAL6LP-YS4LFUA-XMTO6QG";
          myxel.id = "6ER5UMP-KVYYKVY-AL5NAC6-W4KRXTB-UYRQG4R-AFWK66C-RWOULMW-EATTVQV";
          myeck.id = "NLGUPGG-XFGRDSE-43MQEXO-TLEW2XD-DMOL6RM-RPQ4IFQ-GENDXPF-PM7NQAO";
          zendows.id = "4JS6YSF-OBZFPYW-B3OUF4G-R6DVOZ4-KFAVGFY-NT4J223-E44HK3D-GPYAFQP";
          zexel.id = "VYG4QAC-SY7ET5F-CHIPQUN-TP6P7WN-LQCT3HO-UBS73JG-ZGOKCLG-SHWZOAN";
        };

        # Simplify boilerplate folders
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
      # Ensure creation of config directory
      tmpfiles.settings.syncthing = {
        ${cfg.configDir} = {
          d = {
            user = cfg.user;
            group = cfg.group;
          };
        };
      };

      #!! Syncthing needs to start after mounting or there is a risk of file deletion
      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/syncthing.nix#L646
      #?? systemctl status
      services.syncthing = mkIf (isString cfg.mount) {
        after = [cfg.mount];
        bindsTo = [cfg.mount]; # Start/stop service on mount/unmount
      };
    };
  };
}
