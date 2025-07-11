{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.sshd;
in {
  options.custom.services.sshd = {
    enable = mkEnableOption "sshd";

    port = mkOption {
      default =
        if config.custom.containers.forgejo.enable
        then 2222
        else 22;

      type = types.int;
    };
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/SSH_public_key_authentication
    # ssh-copy-id <user>@<host>
    services.openssh = {
      enable = true;
      ports = [cfg.port];

      hostKeys = [
        {
          path = "/etc/ssh/id_ed25519";
          type = "ed25519";
        }
      ];

      # https://infosec.mozilla.org/guidelines/openssh.html
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
