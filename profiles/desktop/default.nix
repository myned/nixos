{
  custom = {
    full = true;
    profile = "desktop";
    desktop = "niri";
    wallpaper = true;

    services = {
      ollama.download = true;
      power-profiles-daemon.enable = true;
    };
  };
}
