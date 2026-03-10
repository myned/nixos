{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.files.agenix;
in {
  options.custom.files.agenix = {
    enable = mkEnableOption "agenix";

    secrets = mkOption {
      description = "List of secrets to add to config.age.secrets";
      default = [];
      example = ["secret.key"];
      type = with types; listOf str;
    };
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Agenix
    # https://github.com/ryantm/agenix
    age = {
      identityPaths = ["/etc/ssh/id_ed25519"]; #!! Must be set without sshd

      secrets = listToAttrs (forEach cfg.secrets (secret:
        nameValuePair secret {
          file = "${inputs.self}/secrets/${secret}";
        }));
    };
  };
}
