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
    };

    services = {
      ollama.download = "high";
      power-profiles-daemon.enable = true;
      wallpaper.enable = true;
    };

    settings = {
      # TODO: Enable when profile is persisted across reboots
      # https://github.com/pop-os/system76-power/issues/263
      #// system76.enable = true;
    };
  };
}
