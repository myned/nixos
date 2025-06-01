{config, ...}: {
  custom = {
    full = true;
    profile = "desktop";
    desktop = "niri";

    containers = {
      enable = true;
      user = config.custom.username;

      ovenmediaengine = {
        #// enable = true;
        bind = "127.0.0.1";
      };
    };

    services = {
      ollama.download = "high";
      #// power-profiles-daemon.enable = true;
      wallpaper.enable = true;
    };

    settings = {
      system76.enable = true;
    };
  };
}
