{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs._1password;
  hm = config.home-manager.users.${config.custom.username};

  _1password = getExe config.programs._1password-gui.package;
in {
  options.custom.programs._1password = {
    enable = mkOption {default = false;};
    agent = mkOption {default = true;};
    browser = mkOption {default = null;};
    git = mkOption {default = true;};
    service = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    programs = {
      # https://developer.1password.com/
      _1password.enable = true; # CLI

      #!! Non-free license
      # https://1password.com/
      _1password-gui = {
        enable = true;
        #// package = pkgs._1password-gui-beta;
        polkitPolicyOwners = [config.custom.username]; # Desktop integration
      };
    };

    # https://wiki.nixos.org/wiki/1Password#Unlocking_browser_extensions
    environment.etc = mkIf (!isNull cfg.browser) {
      "1password/custom_allowed_browsers" = {
        mode = "0755";
        text = cfg.browser;
      };
    };

    systemd.user.services."1password" = mkIf cfg.service {
      enable = true;
      wantedBy = ["graphical-session.target"];

      unitConfig = {
        Description = "Launch 1Password in the background";
        After = ["graphical-session.target"];
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${_1password} --silent";
      };
    };

    home-manager.sharedModules = mkIf cfg.agent [
      {
        # https://developer.1password.com/docs/ssh/get-started#step-4-configure-your-ssh-or-git-client
        home.sessionVariables = {
          SSH_AUTH_SOCK = "${hm.home.homeDirectory}/.1password/agent.sock";
        };

        programs = {
          # https://github.com/NixOS/nixpkgs/issues/230357
          git.signing.signer = mkIf cfg.git (getExe' config.programs._1password-gui.package "op-ssh-sign");

          # ssh.extraConfig = ''
          #   Host *
          #     IdentityAgent ${hm.home.homeDirectory}/.1password/agent.sock
          # '';
        };
      }
    ];
  };
}
