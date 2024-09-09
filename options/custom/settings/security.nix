{ config, lib, ... }:

with lib;

let
  cfg = config.custom.settings.security;
in
{
  options.custom.settings.security.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # Bypass password prompts
    security = {
      sudo.wheelNeedsPassword = false;

      # https://wiki.nixos.org/wiki/Sway#Using_Home_Manager
      polkit = {
        enable = true;

        # https://wiki.archlinux.org/title/Polkit#Bypass_password_prompt
        extraConfig = ''
          polkit.addRule(function(action, subject) {
            if (subject.isInGroup("wheel")) { return polkit.Result.YES; }
          });
        '';
      };
    };
  };
}
