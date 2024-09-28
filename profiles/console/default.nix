{
  config,
  inputs,
  lib,
  options,
  pkgs,
  ...
}: {
  imports = [inputs.jovian-nixos.nixosModules.default];

  custom = {
    minimal = true;
    profile = "console";

    desktops.gnome = {
      enable = true;
      gdm = false;
    };

    programs = {
      gnome-shell.enable = true;

      steam = {
        enable = true;

        # BUG: Causes SteamOS crash when emulating scroll wheel in-game
        #// extest = true;
      };
    };

    services.syncthing = {
      enable = true;
      folders =
        lib.getAttrs [
          "SYNC/.ignore"
          "SYNC/game"
        ]
        options.custom.services.syncthing.folders.default;
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
      desktopSession = "gnome";
      user = config.custom.username;
      environment = config.programs.steam.package.steamargs.extraEnv; # Inherit desktop environment
    };

    devices.steamdeck = {
      enable = true;
      enableGyroDsuService = true;
      autoUpdate = true;
    };

    decky-loader.enable = true;
  };
}
