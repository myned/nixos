{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.storage;
in {
  options.custom.settings.storage = {
    enable = mkEnableOption "storage";

    #!! Avoid /dev/disk/by-* for LUKS filesystems to avoid systemd timeout issues
    # https://github.com/NixOS/nixpkgs/issues/250003
    device = mkOption {
      default =
        if cfg.encrypt
        then "/dev/mapper/crypted"
        else "/dev/disk/by-partlabel/ROOT";
    };

    efi = mkOption {
      default = true;
      type = types.bool;
    };

    encrypt = mkOption {
      default = false;
      type = types.bool;
    };

    mnt = mkOption {
      default = [];
      type = types.listOf types.str;
    };

    offset = mkOption {
      default = null;
      type = with types; nullOr int;
    };

    remote = mkOption {
      default = false;
      type = types.bool;
    };

    swap = mkOption {
      default = null;
      type = with types; nullOr int; # GB
    };

    type = mkOption {
      default = "btrfs";
      type = types.enum ["btrfs" "ext4"];
    };

    zram = mkOption {
      default = true;
      type = types.bool;
    };

    key = {
      enable = mkEnableOption "storage.key";

      device = mkOption {
        default = "/dev/disk/by-label/mysk";
        type = types.str;
      };

      path = mkOption {
        default = ".keys/${config.custom.hostname}.key";
        type = types.str;
      };

      # TODO: Enable when systemd stage 1 is officially released
      # https://github.com/orgs/NixOS/projects/66
      systemd = mkOption {
        default = false;
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    boot =
      {
        # https://wiki.nixos.org/wiki/Full_Disk_Encryption
        # https://wiki.archlinux.org/title/Dm-crypt/Device_encryption#Adding_LUKS_keys
        #?? echo -n '<passphrase>' > <keyfile>
        #?? sudo cryptsetup luksAddKey /dev/disk/by-partlabel/luks <keyfile>
        #?? sudo cryptsetup luksDump /dev/disk/by-partlabel/luks
        initrd = mkIf cfg.encrypt {
          # https://wiki.nixos.org/wiki/Full_Disk_Encryption#Unattended_Boot_via_USB
          kernelModules = mkIf cfg.key.enable [
            "nls_cp437"
            "nls_iso8859_1"
            "uas"
            "usb_storage"
            "usbcore"
            "vfat" # FAT32
            "exfat" # exFAT
          ];

          luks.devices.${builtins.baseNameOf cfg.device} =
            {
              device = "/dev/disk/by-partlabel/LUKS";

              # https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)
              allowDiscards = true;

              # https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance
              bypassWorkqueues = true;
            }
            // optionalAttrs cfg.key.enable {
              keyFile = "/key/${cfg.key.path}";
            }
            // optionalAttrs (cfg.key.enable && cfg.key.systemd) {
              keyFileTimeout = 3; # Seconds
            }
            // optionalAttrs (cfg.key.enable && !cfg.key.systemd) {
              fallbackToPassword = true;
              preLVM = false;
            };

          postDeviceCommands = mkIf (cfg.key.enable && !cfg.key.systemd) ''
            sleep 1
            mkdir -p /key
            mount -o ro ${cfg.key.device} /key
          '';

          systemd = mkIf (cfg.key.enable && cfg.key.systemd) {
            enable = true;

            mounts = [
              {
                what = cfg.key.device;
                where = "/key";

                # FIXME: Does not take effect in key.mount
                # Related: https://github.com/NixOS/nixpkgs/issues/250003
                # mountConfig = {
                #   TimeoutSec = 3;
                # };

                unitConfig = {
                  DefaultDependencies = false; # Otherwise decryption is attempted before mount
                };
              }
            ];
          };
        };
      }
      # Enable hibernation on btrfs, relies on fixed-size swap device
      // optionalAttrs ((cfg.type == "btrfs") && (isInt cfg.swap) && (isInt cfg.offset)) {
        # https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation_into_swap_file
        resumeDevice = cfg.device; #?? findmnt -no LABEL -T /var/lib/swapfile
        kernelParams = ["resume_offset=${toString cfg.offset}"]; #?? sudo btrfs inspect-internal map-swapfile -r /var/lib/swapfile
      };

    #!! Imperative partitioning and formatting
    # https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning
    # https://wiki.nixos.org/wiki/Filesystems
    # https://wiki.nixos.org/wiki/Btrfs
    # https://wiki.archlinux.org/title/Btrfs#Quota
    #?? sudo btrfs quota enable /
    fileSystems =
      {
        # Boot partition
        "/boot" = mkIf cfg.efi {
          device = "/dev/disk/by-partlabel/ESP";
          fsType = "vfat"; # FAT32
          mountPoint = "/boot";
          options = ["defaults"];
        };

        # Root partition
        "/" = {
          device = cfg.device;
          fsType = cfg.type;
          mountPoint = "/";

          options =
            [
              "noatime"
            ]
            ++ optionals (cfg.type == "btrfs") [
              "compress=zstd"
              "subvol=/root"
            ];
        };

        "/home" = {
          device = cfg.device;
          fsType = cfg.type;
          mountPoint = "/home";

          options =
            [
              "noatime"
            ]
            ++ optionals (cfg.type == "btrfs") [
              "compress=zstd"
              "subvol=/home"
            ];
        };

        "/nix" = {
          device = cfg.device;
          fsType = cfg.type;
          mountPoint = "/nix";

          options =
            [
              "noatime"
            ]
            ++ optionals (cfg.type == "btrfs") [
              "compress=zstd"
              "subvol=/nix"
            ];
        };
      }
      # Map list of disk labels to /mnt/LABEL with user defaults
      // mergeAttrsList (forEach cfg.mnt (label: {
        "/mnt/${label}" = {
          device = "/dev/disk/by-label/${label}";

          options = [
            "defaults"
            "noatime"
            "nofail"
            "user"
            "exec"
            "x-gvfs-show"
          ];
        };
      }))
      // optionalAttrs cfg.remote (let
        #!! FUSE does not support remount, sometimes causing activation errors on switch
        # https://github.com/libfuse/libfuse/issues/717
        #?? sudo umount /mnt/remote && sudo mount /mnt/remote
        # https://wiki.nixos.org/wiki/SSHFS
        # https://man.archlinux.org/man/sshfs.1
        #?? "/mnt/PATH" = remote "PATH" UID GID "UMASK"
        remote = path: uid: gid: umask: {
          # https://robot.hetzner.com/storage
          device = "u415778@u415778.your-storagebox.de:/home/${path}";
          fsType = "sshfs";

          options = [
            "noatime" # Do not modify access time
            "reconnect" # Gracefully handle network issues
            "default_permissions" # Check local permissions
            "allow_other" # Grant other users access
            "umask=${umask}" # Set permissions mask
            "uid=${toString uid}" # Set user id
            "gid=${toString gid}" # Set group id
            "idmap=user" # Map local users to remote
            "transform_symlinks" # Convert absolute symlinks to relative
            "compression=no" # Save CPU cycles at the cost of transfer speed
            "port=23"
            "IdentityFile=/etc/ssh/id_ed25519" # !! SSH key configured imperatively
            "ServerAliveInterval=15" # Prevent application hangs on reconnect
          ];
        };
      in {
        # Use umask to set sshfs permissions
        #!! Up to 10 simultaneous connections with Hetzner
        #?? docker compose exec CONTAINER cat /etc/passwd
        #// "/mnt/remote/conduwuit" = remote "conduwuit" 300 300 "0077"; # conduit:conduit @ 0700
        #// "/mnt/remote/nextcloud" = remote "nextcloud" 33 33 "0007"; # www-data:www-data @ 0700
        #// "/mnt/remote/syncthing" = remote "syncthing" 237 237 "0077"; # syncthing:syncthing @ 0700
      });

    # Enforce permissions for remote mountpoint
    systemd.tmpfiles.settings.remote = let
      owner = mode: {
        inherit mode;
        user = "root";
        group = "root";
      };
    in
      mkIf cfg.remote {
        "/mnt/remote" = {
          d = owner "0755"; # -rwxr-xr-x
          z = owner "0755"; # -rwxr-xr-x
        };
      };

    # https://wiki.nixos.org/wiki/Swap
    # https://wiki.nixos.org/wiki/Btrfs#Swap_file
    swapDevices = mkIf (isInt cfg.swap) [
      {
        device = "/var/lib/swapfile";
        size = cfg.swap * 1024; # MB
      }
    ];

    # TODO: Use zswap module when available
    # https://github.com/NixOS/nixpkgs/issues/119244
    # https://wiki.nixos.org/wiki/Swap#Enable_zram_swap
    # https://wiki.archlinux.org/title/Zram
    #?? zramctl
    zramSwap = mkIf cfg.zram {
      enable = true;
      memoryPercent = 100;
    };

    # https://wiki.nixos.org/wiki/Btrfs#Scrubbing
    services.btrfs.autoScrub = mkIf (cfg.type == "btrfs") {
      enable = true;
      interval = "weekly";
    };
  };
}
