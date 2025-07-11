{
  disko.devices = {
    disk = {
      master = {
        type = "disk";
        device = "/dev/?";

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

            ROOT = {
              size = "100%";

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
}
