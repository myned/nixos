{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.sudo;
in {
  options.custom.programs.sudo = {
    enable = mkOption {default = false;};
    bypass = mkOption {default = true;};
    confirm = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Sudo
    #?? sudo echo
    security.sudo = {
      enable = true;
      wheelNeedsPassword = !cfg.bypass;
    };

    environment.shellAliases = mkIf cfg.confirm {
      # Interactive confirmation prompt
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
