{
  custom = {
    full = true;
    profile = "desktop";
    wallpaper = true;
    services.power-profiles-daemon.enable = true;

    programs.anime-game-launcher = {
      enable = true;
      genshin-impact = true;
    };
  };
}
