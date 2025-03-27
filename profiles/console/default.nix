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
    profile = "console";
    desktop = "kde";

    desktops = {
      #// gnome.gdm = false;
    };

    programs = {
      #// gnome-shell.enable = true;

      steam = {
        enable = true;

        # BUG: Causes SteamOS crash when emulating scroll wheel in-game
        #// extest = true;
      };
    };

    services = {
      syncthing = {
        enable = true;
        folders =
          lib.getAttrs [
            "SYNC/.ignore"
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

        # Dependencies
        wineWowPackages.stable
      ];
    };
  };

  # https://github.com/Jovian-Experiments/Jovian-NixOS
  # https://jovian-experiments.github.io/Jovian-NixOS/options.html
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      desktopSession = "plasma";
      user = config.custom.username;
    };

    devices.steamdeck = {
      enable = true;
      enableGyroDsuService = true;
      autoUpdate = true;
    };

    decky-loader.enable = true;
  };

  home-manager.sharedModules = [
    {
      # HACK: Manually set DISPLAY variable for use in gamemode
      systemd.user.services.kdeconnect = {
        Service = {
          Environment = ["DISPLAY=:${toString config.xserver.display}"];
        };
      };
    }
  ];
}
