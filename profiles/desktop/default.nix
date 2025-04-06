{
  custom = {
    full = true;
    profile = "desktop";
    desktop = "niri";

    services = {
      ollama.download = "high";
      power-profiles-daemon.enable = true;
      wallpaper.enable = true;
    };
  };
}
