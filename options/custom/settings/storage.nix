{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.storage;
in {
  options.custom.settings.storage = {
    enable = mkOption {default = false;};
    mnt = mkOption {default = [];};
    remote = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # Enforce permissions for mountpoint directory
    systemd.tmpfiles.settings.storage = {
      "/mnt/remote" = {
        d = {
          mode = "0755";
          user = "root";
          group = "root";
        };
      };
    };

    #!! FUSE does not support remount, sometimes causing activation errors on switch
    # https://github.com/libfuse/libfuse/issues/717
    #?? sudo umount /mnt/remote && sudo mount /mnt/remote
    # https://wiki.nixos.org/wiki/SSHFS
    # https://man.archlinux.org/man/sshfs.1
    fileSystems = let
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
    in
      # Map list of disk labels to /mnt/LABEL with user defaults
      mergeAttrsList (forEach cfg.mnt (label: {
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
      // optionalAttrs cfg.remote {
        # Use umask to set sshfs permissions
        #!! Up to 10 simultaneous connections with Hetzner
        #?? docker compose exec CONTAINER cat /etc/passwd
        #// "/mnt/remote/conduwuit" = remote "conduwuit" 300 300 "0077"; # conduit:conduit @ 0700
        #// "/mnt/remote/nextcloud" = remote "nextcloud" 33 33 "0007"; # www-data:www-data @ 0700
        #// "/mnt/remote/syncthing" = remote "syncthing" 237 237 "0077"; # syncthing:syncthing @ 0700
      };
  };
}
