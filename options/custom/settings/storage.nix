{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.storage;
in {
  imports = [inputs.disko.nixosModules.disko];

  options.custom.settings.storage = {
    enable = mkEnableOption "storage";

    defaultMounts = mkOption {
      default = [];
      description = "Devices to mount with default options under /mnt/*";
      example = ["/dev/disk/by-label/external"];
      type = with types; listOf path;
    };

    prebuiltImage = mkOption {
      default = false;
      description = "Whether the disk layout follows the official NixOS image";
      example = true;
      type = types.bool;
    };

    swapSize = mkOption {
      default = null;
      description = "Size of the swapfile to create, in GiB";
      example = 32;
      type = with types; nullOr int;
    };

    zramSize = mkOption {
      default = 100;
      description = "Size of the zram device to create, in percentage of memory capacity";
      example = 50;
      type = with types; nullOr int;
    };

    key = {
      enable = mkEnableOption "key";

      device = mkOption {
        default = "/dev/disk/by-label/mysk";
        description = "Path to the key device for mount during initrd";
        example = "/dev/disk/by-label/key";
        type = types.path;
      };

      path = mkOption {
        default = "/key/.keys/${config.custom.hostname}.key";
        description = "Path to the key file on device";
        example = "/key/secret.key";
        type = types.path;
      };
    };

    raid = {
      enable = mkEnableOption "raid";

      devices = mkOption {
        description = "List of device paths to be added to a btrfs RAID, explicitly required";
        example = ["/dev/sda" "/dev/sdb"];
        type = with types; listOf path;
      };

      label = mkOption {
        default = "local";
        description = "Filesystem label of the RAID device";
        example = "raid";
        type = types.str;
      };

      type = mkOption {
        default = "raid1";
        description = "Type of btrfs RAID to create";
        example = "raid10";
        type = with types; enum ["raid0" "raid1" "raid1c3" "raid1c4" "raid10"]; #!! RAID5/6 not currently stable
      };
    };

    root = {
      device = mkOption {
        description = "Path to the root device, explicitly required";
        example = "/dev/nvme0n1";
        type = types.path;
      };

      encrypted = mkOption {
        default = false;
        description = "Whether the root device is encrypted via LUKS";
        example = true;
        type = types.bool;
      };

      type = mkOption {
        default = "btrfs";
        description = "Filesystem type of the root device";
        example = "ext4";
        type = with types; enum ["btrfs" "ext4"];
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      initrd = {
        systemd.enable = true;

        # https://wiki.nixos.org/wiki/Full_Disk_Encryption#Unattended_Boot_via_USB
        kernelModules = optionals cfg.key.enable [
          "nls_cp437"
          "nls_iso8859_1"
          "uas"
          "usb_storage"
          "usbcore"
          "vfat" # FAT32
          "exfat" # exFAT
        ];

        # FIXME: Does not work
        # TODO: Wait for graphics driver to initialize before decryption prompt appears
        systemd.mounts = optionals cfg.key.enable [
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

    # https://github.com/nix-community/disko
    disko.devices = let
      # https://github.com/nix-community/disko/blob/master/example/btrfs-subvolumes.nix
      # https://github.com/nix-community/disko/blob/master/example/btrfs-only-root-subvolume.nix
      # https://btrfs.readthedocs.io/en/latest/mkfs.btrfs.html#options
      btrfs = {
        type = "btrfs";
        extraArgs = ["-f"];
        mountpoint = "/";

        mountOptions = [
          "compress=zstd"

          # TODO: Revisit for audit logging
          "noatime"
        ];
      };

      # https://github.com/nix-community/disko/blob/master/example/simple-efi.nix
      ext4 = {
        type = "filesystem";
        format = "ext4";
      };

      content =
        if cfg.root.type == "btrfs"
        then btrfs
        else if cfg.root.type == "ext4"
        then ext4
        else null;
    in
      mkIf (!cfg.prebuiltImage) {
        disk =
          {
            main = {
              type = "disk";
              device = cfg.root.device;

              content = {
                type = "gpt";

                partitions =
                  # https://github.com/nix-community/disko/blob/master/example/gpt-bios-compat.nix
                  optionalAttrs config.custom.settings.boot.grub.enable {
                    boot = {
                      type = "EF02";
                      size = "1M";
                    };
                  }
                  # https://github.com/nix-community/disko/blob/master/example/simple-efi.nix
                  // optionalAttrs config.custom.settings.boot.systemd-boot.enable {
                    esp = {
                      type = "EF00";
                      size = "1G";

                      content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = "/boot";
                      };
                    };
                  }
                  // optionalAttrs (!cfg.root.encrypted) {
                    root = {
                      inherit content;
                      size = "100%";
                    };
                  }
                  // optionalAttrs cfg.root.encrypted {
                    # https://github.com/nix-community/disko/blob/master/example/luks-btrfs-subvolumes.nix
                    luks = {
                      size = "100%";

                      content = {
                        inherit content;
                        type = "luks";
                        name = "crypted";
                        passwordFile = "/tmp/secret.key"; # Only during installation
                        additionalKeyFiles = [cfg.key.path];

                        settings = {
                          allowDiscards = true; # https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)
                          bypassWorkqueues = true; # https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance
                        };
                      };
                    };
                  };
              };
            };
          }
          # BUG: Formatting only, disko does not use filesystem labels to mount
          # https://github.com/nix-community/disko/issues/184
          // optionalAttrs cfg.raid.enable {
            raid = {
              type = "disk";
              device = elemAt cfg.raid.devices 0; # Arbitrarily use the first device

              content = {
                type = "gpt";

                partitions = {
                  ${cfg.raid.label} = {
                    label = cfg.raid.label;
                    size = "100%";

                    content = {
                      type = "btrfs";
                      extraArgs = ["-f" "-m" cfg.raid.type "-d" cfg.raid.type] ++ cfg.raid.devices;
                    };
                  };
                };
              };
            };
          };
      };

    # https://wiki.nixos.org/wiki/Filesystems
    # https://nixos.org/manual/nixos/stable/#sec-installation-manual-partitioning
    fileSystems =
      # Map list of disks to /mnt/<device> with user defaults
      mergeAttrsList (forEach cfg.defaultMounts (device: {
        "/mnt/${baseNameOf device}" = {
          inherit device;

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
      # Mount filesystem without disko, assumes prebuilt image instead of iso installer
      # https://wiki.nixos.org/wiki/NixOS_on_ARM/Installation
      // optionalAttrs (cfg.prebuiltImage) {
        "/" = {
          device = cfg.root.device;
          fsType = cfg.root.type;
          options = ["noatime"];
        };
      }
      # Mount RAID filesystem created by disko
      // optionalAttrs cfg.raid.enable {
        "/mnt/${cfg.raid.label}" = {
          device = "/dev/disk/by-label/${cfg.raid.label}";

          options = [
            "compress=zstd"
            "noatime"
            "nofail"
          ];
        };
      };
    # // optionalAttrs cfg.remote (let
    #   #!! FUSE does not support remount, sometimes causing activation errors on switch
    #   # https://github.com/libfuse/libfuse/issues/717
    #   #?? sudo umount /mnt/remote && sudo mount /mnt/remote
    #   # https://wiki.nixos.org/wiki/SSHFS
    #   # https://man.archlinux.org/man/sshfs.1
    #   #?? "/mnt/<path>" = remote "<path>" <uid> <gid> "<umask>"
    #   remote = path: uid: gid: umask: {
    #     # https://robot.hetzner.com/storage
    #     device = "user@user.your-storagebox.de:/home/${path}";
    #     fsType = "sshfs";

    #     options = [
    #       "noatime" # Do not modify access time
    #       "reconnect" # Gracefully handle network issues
    #       "default_permissions" # Check local permissions
    #       "allow_other" # Grant other users access
    #       "umask=${umask}" # Set permissions mask
    #       "uid=${toString uid}" # Set user id
    #       "gid=${toString gid}" # Set group id
    #       "idmap=user" # Map local users to remote
    #       "transform_symlinks" # Convert absolute symlinks to relative
    #       "compression=no" # Save CPU cycles at the cost of transfer speed
    #       "port=23"
    #       "IdentityFile=/etc/ssh/id_ed25519" # !! SSH key configured imperatively
    #       "ServerAliveInterval=15" # Prevent application hangs on reconnect
    #     ];
    #   };
    # in {
    #   # Use umask to set sshfs permissions
    #   #!! Up to 10 simultaneous connections with Hetzner
    #   #?? docker compose exec <container> cat /etc/passwd
    #   #// "/mnt/remote/conduwuit" = remote "conduwuit" 300 300 "0077"; # conduit:conduit @ 0700
    #   #// "/mnt/remote/nextcloud" = remote "nextcloud" 33 33 "0007"; # www-data:www-data @ 0700
    #   #// "/mnt/remote/syncthing" = remote "syncthing" 237 237 "0077"; # syncthing:syncthing @ 0700
    # });

    # Enforce permissions for remote mountpoint
    # systemd.tmpfiles.settings.remote = let
    #   owner = mode: {
    #     inherit mode;
    #     user = "root";
    #     group = "root";
    #   };
    # in
    #   mkIf cfg.remote {
    #     "/mnt/remote" = {
    #       d = owner "0755"; # -rwxr-xr-x
    #       z = owner "0755"; # -rwxr-xr-x
    #     };
    #   };

    # https://wiki.nixos.org/wiki/Swap
    # https://wiki.nixos.org/wiki/Btrfs#Swap_file
    swapDevices = optionals (!isNull cfg.swapSize) [
      {
        device = "/var/lib/swapfile";
        size = cfg.swapSize * 1024; # MiB
      }
    ];

    # TODO: Use zswap module when available
    # https://github.com/NixOS/nixpkgs/issues/119244
    # https://wiki.nixos.org/wiki/Swap#Enable_zram_swap
    # https://wiki.archlinux.org/title/Zram
    #?? zramctl
    zramSwap = optionalAttrs (!isNull cfg.zramSize) {
      enable = true;
      memoryPercent = cfg.zramSize;
    };

    # https://wiki.nixos.org/wiki/Btrfs#Scrubbing
    services.btrfs.autoScrub = optionalAttrs (cfg.root.type == "btrfs") {
      enable = true;
      interval = "weekly";
    };
  };
}
