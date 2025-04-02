{
  custom = {
    full = true;
    profile = "desktop";
    desktop = "niri";
    wallpaper = true;

    services = {
      ollama.download = "medium";
      power-profiles-daemon.enable = true;
    };
  };
}
