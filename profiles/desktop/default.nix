{config, ...}: {
  custom = {
    full = true;
    profile = "desktop";
    desktop = "niri";

    arion = {
      enable = true;
      user = config.custom.username;
    };

    games = {
      enable = true;
      #// _7-days-to-die.enable = true;
      #// abiotic-factor.enable = true;
      #// baba-is-you.enable = true;
      cemu.enable = true;
      elden-ring.enable = true;
      fist.enable = true;
      #// remnant.enable = true;
      tunic.enable = true;
      vintagestory.enable = true;
    };

    services = {
      ollama.download = ["potato" "high"];
      power-profiles-daemon.enable = true;
      sunshine.enable = true;

      # BUG: Does not persist profile across reboots
      # https://github.com/pop-os/system76-power/issues/263
      #// system76.enable = true;

      #// tuned.enable = true;
      #// wallpaper.enable = true;
    };

    vms = {
      enable = true;
      myndows.enable = true;
    };
  };
}
