{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.security;
in {
  options.custom.settings.security.enable = mkOption {default = false;};

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

    environment.shellAliases = {
      # Sudo confirmation prompt
      sudo = pkgs.writeShellScript "sudo" ''
        read -p "Execute as root? [Y/n] "

        case "$REPLY" in
          "" | [Yy])
            command sudo "$@"
            ;;
          *)
            exit 1
            ;;
        esac
      '';
    };
  };
}
