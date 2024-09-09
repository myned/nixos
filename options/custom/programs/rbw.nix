{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.programs.rbw;
in
{
  options.custom.programs.rbw.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/doy/rbw
    #!! Register with API secrets before using
    #?? rbw register
    #?? rbw login
    programs.rbw = {
      enable = true;

      # https://github.com/doy/rbw?tab=readme-ov-file#configuration
      settings = {
        email = "myned@bjork.tech";
        pinentry = pkgs.pinentry-gnome3;
      };
    };
  };
}
