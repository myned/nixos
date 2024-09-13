{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  custom.hostname = "myeck";

  fileSystems = {
    "/mnt/external" = {
      device = "/dev/disk/by-label/external";
      options = [
        "noatime"
        "nofail"
        "users"
        "exec"
        "x-gvfs-show"
      ];
    };
  };

  systemd.tmpfiles.rules = ["z /mnt/external 0755 myned users"];
}
