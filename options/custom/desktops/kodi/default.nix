{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.kodi;
in {
  options.custom.desktops.kodi = {
    enable = mkOption {default = false;};
    firewall = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://github.com/xbmc/xbmc
    # https://kodi.wiki/view/Main_Page
    # https://wiki.archlinux.org/title/Kodi
    # https://wiki.nixos.org/wiki/Kodi
    services = {
      displayManager.autoLogin = {
        enable = true;
        user = "kodi";
      };

      xserver = {
        enable = true;
        displayManager.lightdm.greeter.enable = false;

        desktopManager.kodi = {
          enable = true;

          # https://wiki.nixos.org/wiki/Kodi#Plugins
          package = pkgs.unstable.kodi-gbm.withPackages (kodiPackages:
            with kodiPackages; [
              youtube # https://github.com/anxdpanic/plugin.video.youtube
            ]);
        };
      };
    };

    # https://kodi.wiki/view/Smartphone/tablet_remotes#Firewall
    # https://wiki.nixos.org/wiki/Kodi#Access_from_other_machines
    networking.firewall = mkIf cfg.firewall {
      allowedTCPPorts = [8080];
      allowedUDPPorts = [9777];
    };

    users.users.kodi = {
      isNormalUser = true;
    };

    home-manager.users.kodi = {
      programs = {
        home-manager.enable = true;

        kodi = {
          enable = true;
          package = config.services.xserver.desktopManager.kodi.package;

          # advancedsettings.xml
          # https://kodi.wiki/view/Advancedsettings.xml
          settings = {
            # guisettings.xml
            # https://kodi.wiki/view/Advancedsettings.xml#guisettings.xml_Setting_Conversion
            # https://github.com/xbmc/xbmc/blob/master/system/settings/settings.xml

            # https://kodi.wiki/view/Webserver
            services = {
              webserver = "true";
              webserverauthentication = "false";
            };
          };
        };
      };
    };
  };
}
