{
  disko.devices = {
    disk = {
      master = {
        type = "disk";
        device = "/dev/nvme0n1";

        content = {
          type = "gpt";

          partitions = {
            ESP = {
              type = "EF00";
              size = "512M";

              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            LUKS = {
              size = "100%";

              content = {
                type = "luks";
                name = "crypted";
                passwordFile = "/tmp/secret.key";
                additionalKeyFiles = ["/key/.keys/mynix.key"];

                settings = {
                  allowDiscards = true; # https://wiki.archlinux.org/title/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)
                  bypassWorkqueues = true; # https://wiki.archlinux.org/title/Dm-crypt/Specialties#Disable_workqueue_for_increased_solid_state_drive_(SSD)_performance
                };

                content = {
                  type = "btrfs";
                  extraArgs = ["-f"];

                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";

                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };

                    "/home" = {
                      mountpoint = "/home";

                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };

                    "/nix" = {
                      mountpoint = "/nix";

                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
