{ config, lib, ... }:

with lib;

let
  cfg = config.custom.settings.mounts;
in
{
  options.custom.settings.mounts.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # Enforce permissions for mountpoint directory
    systemd.tmpfiles.rules = [ "d /mnt/remote 0755 root root" ];

    #!! FUSE does not support remount, sometimes causing activation errors on switch
    # https://github.com/libfuse/libfuse/issues/717
    #?? sudo umount /mnt/remote && sudo mount /mnt/remote
    # https://wiki.nixos.org/wiki/SSHFS
    # https://man.archlinux.org/man/sshfs.1
    fileSystems =
      let
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
      {
        # Use umask to set sshfs permissions
        #!! Up to 10 simultaneous connections with Hetzner
        #?? docker compose exec CONTAINER cat /etc/passwd
        "/mnt/remote/conduwuit" = remote "conduwuit" 300 300 "0077"; # conduit:conduit @ 0700
        #// "/mnt/remote/nextcloud" = remote "nextcloud" 33 33 "0007"; # www-data:www-data @ 0700
        "/mnt/remote/syncthing" = remote "syncthing" 237 237 "0077"; # syncthing:syncthing @ 0700
      };

    # https://wiki.nixos.org/wiki/Rclone
    # https://docs.hetzner.com/robot/storage-box/access/access-ssh-rsync-borg/#rclone
    #!! SSH keys configured imperatively
    #!! rclone attempts to write to immutable config; need to manually merge changes
    # https://github.com/rclone/rclone/issues/3655
    # TODO: Attempt to use rclone after daemon is fixed
    # https://github.com/rclone/rclone/issues/5664
    # environment.etc."rclone.conf".text = ''
    #   [remote]
    #   type = sftp
    #   host = u415778.your-storagebox.de
    #   user = u415778
    #   port = 23
    #   key_file = /etc/ssh/id_ed25519
    #   shell_type = unix
    # '';

    # fileSystems."/mnt/remote" = {
    #   device = "remote:/home";
    #   fsType = "rclone";

    #   options = [
    #     "nodev"
    #     "nofail"
    #     "reconnect"
    #     "args2env" # Pass secrets as environment variables
    #     "default_permissions"
    #     "config=/etc/rclone.conf"
    #   ];
    # };
  };
}
