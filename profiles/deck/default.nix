{
  config,
  inputs,
  lib,
  options,
  pkgs,
  ...
}: {
  imports = [
    inputs.jovian-nixos.nixosModules.default
  ];

  custom = {
    minimal = true;
    profile = "deck";
    desktop = "kde";

    programs = {
      #// kodi.enable = true;
      steam.enable = true;
    };

    services = {
      syncthing = {
        enable = true;
        folders =
          lib.getAttrs [
            "SYNC/common"
            "SYNC/game"
          ]
          options.custom.services.syncthing.folders.default;
      };
    };

    settings = {
      boot = {
        console-mode = 5; # Proper orientation
        kernel = pkgs.linuxPackages_jovian;
      };

      packages.extra = with pkgs; [
        # GUI applications
        bitwarden
        gnome-tweaks
        heroic
        lutris
        xivlauncher

        # CLI applications
        er-patcher # Elden Ring fixes
        winetricks
      ];
    };
  };

  # https://github.com/Jovian-Experiments/Jovian-NixOS
  # https://jovian-experiments.github.io/Jovian-NixOS/options.html
  jovian = {
    decky-loader.enable = true;

    devices.steamdeck = {
      enable = true;
      enableGyroDsuService = true;
      autoUpdate = true;
    };

    steam = {
      enable = true;
      autoStart = true;
      desktopSession = "plasma"; #?? services.displayManager.sessionData.sessionNames
      user = config.custom.username;
    };
  };
}
