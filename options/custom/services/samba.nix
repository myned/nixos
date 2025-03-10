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
    services.samba =
      if (versionAtLeast version "24.11")
      then {
        enable = true;
        nmbd.enable = false;
        nsswins = false;
        openFirewall = true;

        # https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html
        settings = {
          Public.path = "/home/${config.custom.username}/Public";
          SYNC.path = config.custom.sync;

          global = {
            "acl allow execute always" = "yes"; # Required for execution on Windows
            "allow insecure wide links" = "yes";
            "browseable" = "no";
            "follow symlinks" = "yes";
            "force user" = config.custom.username;
            "hostname lookups" = "yes";
            "hosts allow" = "100.64.0.0/255.192.0.0"; # Tailscale
            "inherit owner" = "unix only";
            "inherit permissions" = "yes";
            "logging" = "systemd";
            "map to guest" = "bad password";
            "wide links" = "yes";
            "writeable" = "yes";
          };
        };
      }
      else {};
  };
}
