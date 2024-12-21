{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs._1password;
in {
  options.custom.programs._1password = {
    enable = mkOption {default = false;};
    agent = mkOption {default = true;};
    browser = mkOption {default = null;};
  };

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

    # https://wiki.nixos.org/wiki/1Password#Unlocking_browser_extensions
    environment.etc = mkIf (isString cfg.browser) {
      "1password/custom_allowed_browsers" = {
        mode = "0755";

        text = ''
          ${cfg.browser}
        '';
      };
    };

    home-manager.users.${config.custom.username} = {
      programs.ssh.extraConfig = mkIf cfg.agent ''
        Host *
          IdentityAgent ~/.1password/agent.sock
      '';
    };
  };
}
