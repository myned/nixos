{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.rbw;
in {
  options.custom.programs.rbw = {
    enable = mkOption {default = false;};
  };

  config = {
    # https://github.com/fdw/rofi-rbw
    environment.systemPackages = [pkgs.rofi-rbw];

    home-manager.sharedModules = mkIf cfg.enable [
      {
        # https://github.com/doy/rbw
        #!! Register with API secrets before using
        #?? rbw register
        #?? rbw login
        programs.rbw = {
          enable = true;

          # https://github.com/doy/rbw?tab=readme-ov-file#configuration
          settings = {
            base_url = "https://vault.${config.custom.domain}";
            email = "${config.custom.username}@${config.custom.domain}";
            lock_timeout = 24 * 60 * 60; # Hours
            sync_interval = 15 * 60; # Minutes

            pinentry =
              if config.custom.menu == "rofi"
              then pkgs.pinentry-rofi # https://github.com/plattfot/pinentry-rofi
              else pkgs.pinentry-gnome3; # https://github.com/gpg/pinentry
          };
        };

        # TODO: Enable input emulation when merged (uinput.enable?)
        # https://github.com/NixOS/nixpkgs/pull/303745
        # https://github.com/fdw/rofi-rbw?tab=readme-ov-file#configuration
        xdg.configFile = {
          "rofi-rbw.rc".text = let
            keybindings = concatStringsSep "," [
              "Ctrl+1:print:username"
              "Ctrl+2:print:password"
              "Ctrl+3:print:totp"
              "Alt+1:type:delay:username"
              "Alt+2:type:delay:password"
              "Alt+3:type:delay:totp"
              "Alt+u:copy:username"
              "Alt+p:copy:password"
              "Alt+t:copy:totp"
              "Alt+s:sync"
            ];
          in ''
            action=copy
            keybindings=${keybindings}
            no-help=true
            prompt=󰌾
            selector=${config.custom.menu}
            target=menu
          '';
        };
      }
    ];
  };
}
