{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.samba;
in {
  options.custom.services.samba.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Samba
    # https://gitlab.com/samba-team/samba
    #!! User configuration is imperative
    #?? sudo smbpasswd -a $USER
    services.samba = {
      enable = true;
      openFirewall = true;

      shares = {
        Public.path = "/home/${config.custom.username}/Public";
        SYNC.path = "/home/${config.custom.username}/SYNC";
      };

      extraConfig = ''
        logging = systemd

        hosts allow = 127.0.0.1 myndows 192.168.111.

        browseable = yes
        writeable = yes
        force user = ${config.custom.username}
        map to guest = bad password
        inherit owner = unix only
        inherit permissions = yes
        follow symlinks = yes
        wide links = yes
        allow insecure wide links = yes
      '';
    };
  };
}
