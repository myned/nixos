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
      nmbd.enable = false;
      nsswins = false;

      # https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
      settings = {
        Public.path = "/home/${config.custom.username}/Public";
        SYNC.path = "/home/${config.custom.username}/SYNC";

        global = {
          "allow insecure wide links" = "yes";
          "browseable" = "no";
          "follow symlinks" = "yes";
          "force user" = config.custom.username;
          "hostname lookups" = "yes";
          "hosts allow" = "192.168.111.";
          "inherit owner" = "unix only";
          "inherit permissions" = "yes";
          "logging" = "systemd";
          "map to guest" = "bad password";
          "wide links" = "yes";
          "writeable" = "yes";
        };
      };
    };
  };
}
