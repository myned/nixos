{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.postfix;
in {
  options.custom.services.postfix = {
    enable = mkEnableOption "postfix";
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Postfix_for_Gmail
    services.postfix = {
      enable = true;
    };
  };
}
