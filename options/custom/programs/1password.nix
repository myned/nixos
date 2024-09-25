{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs._1password;
in {
  options.custom.programs._1password.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    programs = {
      # https://developer.1password.com/
      _1password.enable = true; # CLI

      #!! Non-free license
      # https://1password.com/
      _1password-gui = {
        enable = true;
        package = pkgs._1password-gui-beta;
        polkitPolicyOwners = [config.custom.username]; # Desktop integration
      };
    };
  };
}
