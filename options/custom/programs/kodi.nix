{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.kodi;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.kodi = {
    enable = mkEnableOption "kodi";

    firewall = mkOption {
      default = false;
      type = types.bool;
    };

    package = mkOption {
      default =
        pkgs.kodi-gbm.withPackages (kodiPackages:
          forEach cfg.plugins (plugin: kodiPackages.${plugin}));

      type = types.package;
    };

    # https://wiki.nixos.org/wiki/Kodi#Plugins
    plugins = mkOption {
      default = [
        "joystick" # https://github.com/xbmc/peripheral.joystick
        "sendtokodi" # https://github.com/firsttris/plugin.video.sendtokodi
        "sponsorblock" # https://github.com/siku2/script.service.sponsorblock
        "trakt" # https://github.com/trakt/script.trakt
        "youtube" # https://github.com/anxdpanic/plugin.video.youtube
      ];

      type = with types; listOf str;
    };
  };

  config = mkIf cfg.enable {
    # https://kodi.wiki/view/Smartphone/tablet_remotes#Firewall
    # https://wiki.nixos.org/wiki/Kodi#Access_from_other_machines
    networking.firewall = mkIf cfg.firewall {
      allowedTCPPorts = [8888];
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
        };

        #!! Imperative synced files
        # https://kodi.wiki/view/Advancedsettings.xml
        # https://kodi.wiki/view/Advancedsettings.xml#guisettings.xml_Setting_Conversion
        # https://github.com/xbmc/xbmc/blob/master/system/settings/settings.xml
        home.file = let
          sync = source: {
            source = hm.lib.file.mkOutOfStoreSymlink "${config.custom.syncDir}/${source}";
            force = true;
          };
        in {
          ".kodi/userdata" = sync "common/config/kodi/userdata";
        };
      }
    ];
  };
}
