{
  config,
  lib,
  ...
}:
with lib; let
  hm = config.home-manager.users.${config.custom.username};
in {
  custom = {
    profile = "sbc";
    #// desktop = "kodi";

    programs = {
      fastfetch.greet = true;
    };

    containers = {
      enable = true;
      boot = true;
      beszel.enable = true;
      homeassistant.enable = true;
      portainer.enable = true;
    };

    services = {
      prometheus.enable = true;

      # pipewire = {
      #   enable = true;
      #   pulseaudio = false;
      #   system = true;
      # };

      borgmatic = {
        enable = true;

        sources =
          [
            config.custom.containers.directory
          ]
          ++ optionals hm.programs.kodi.enable [
            hm.programs.kodi.datadir
          ];
      };
    };

    settings = {
      networking = {
        networkmanager = true;
        wifi = true;
      };
    };
  };
}
