{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.kodi;
in {
  options.custom.programs.kodi = {
    enable = mkEnableOption "kodi";
    firewall = mkOption {default = false;};

    package = mkOption {
      default =
        pkgs.kodi-gbm.withPackages (kodiPackages:
          forEach cfg.plugins (plugin: kodiPackages.${plugin}));

      type = types.package;
    };

    # https://wiki.nixos.org/wiki/Kodi#Plugins
    plugins = mkOption {
      default = [
        "youtube" # https://github.com/anxdpanic/plugin.video.youtube
      ];

      type = with types; listOf str;
    };
  };

  config = mkIf cfg.enable {
    # https://kodi.wiki/view/Smartphone/tablet_remotes#Firewall
    # https://wiki.nixos.org/wiki/Kodi#Access_from_other_machines
    networking.firewall = mkIf cfg.firewall {
      allowedTCPPorts = [8080];
      allowedUDPPorts = [9777];
    };

    home-manager.sharedModules = [
      {
        # https://github.com/xbmc/xbmc
        # https://kodi.wiki/view/Main_Page
        # https://wiki.archlinux.org/title/Kodi
        # https://wiki.nixos.org/wiki/Kodi
        programs.kodi = {
          enable = true;
          package = cfg.package;

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
              webserverport = "8888";
            };
          };
        };
      }
    ];
  };
}
