{
  config,
  lib,
  ...
}:
with lib; {
  custom = {
    profile = "sbc";
    desktop = "kodi";

    programs = {
      fastfetch.greet = true;
    };

    containers = {
      enable = true;
      boot = true;
      homeassistant.enable = true;
    };

    services = {
      pipewire = {
        enable = true;
        pulseaudio = false;
        system = true;
      };

      #// tailscale.cert = true;

      borgmatic = {
        enable = true;

        sources =
          [
            config.custom.containers.directory
          ]
          ++ optionals config.home-manager.users.kodi.programs.kodi.enable [
            config.home-manager.users.kodi.programs.kodi.datadir
          ];
      };

      # netdata = {
      #   enable = true;
      #   child = true;
      # };
    };

    settings = {
      networking = {
        networkmanager = true;
        wifi = true;
      };
    };
  };
}
