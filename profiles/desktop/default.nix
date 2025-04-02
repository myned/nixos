{
  custom = {
    full = true;
    profile = "desktop";
    desktop = "niri";
    wallpaper = true;

    services = {
      ollama.download = "high";
      power-profiles-daemon.enable = true;
    };
  };
}
