{
  config,
  lib,
  ...
}:
with lib; {
  custom = {
    full = true;
    profile = "desktop";
    desktop = "niri";

    arion = {
      enable = true;
      user = config.custom.username;
    };

    containers = {
      enable = true;
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
      ollama.download = "high";
      #// power-profiles-daemon.enable = true;
      sunshine.enable = true;
      tuned.enable = true;
      #// wallpaper.enable = true;
    };

    settings = {
      # TODO: Enable when profile is persisted across reboots
      # https://github.com/pop-os/system76-power/issues/263
      #// system76.enable = true;
    };

    vms = {
      enable = true;
      myndows.enable = true;
    };
  };
}
