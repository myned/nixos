{
  config,
  inputs,
  lib,
  options,
  ...
}:
with lib; let
  cfg = config.custom.files.agenix;
in {
  options.custom.files.agenix = {
    enable = mkEnableOption "agenix";

    secrets = mkOption {
      description = "Attrset of secrets to add to config.age.secrets with overridable defaults";
      default = {};
      example = {"secret.key" = {};};
      type = types.attrs;
    };
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Agenix
    # https://github.com/ryantm/agenix
    age = {
      identityPaths = ["/etc/ssh/id_ed25519"]; #!! Must be set without sshd
      secrets = mapAttrs (name: value: {file = "${inputs.self}/secrets/${name}";} // value) cfg.secrets;
    };
  };
}
