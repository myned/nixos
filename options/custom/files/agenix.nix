{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.files.agenix;
in {
  # https://wiki.nixos.org/wiki/Agenix
  # https://github.com/ryantm/agenix
  options.custom.files.agenix.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    age.identityPaths = ["/etc/ssh/id_ed25519"]; # !! Must be set without sshd
  };
}
