{config, ...}: {
  custom = {
    full = true;
    profile = "desktop";
    desktop = "niri";

    containers = {
      enable = true;
      user = config.custom.username;
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
