{config, ...}: {
  custom = {
    full = true;

    # FIXME: Use "laptop" profile
    profile = "desktop"; # Inherit desktop profile

    desktop = "niri";

    containers = {
      enable = true;
      user = config.custom.username;
    };

    services = {
      #// auto-cpufreq.enable = true;
      wluma.enable = true;

      ollama = {
        acceleration = false;
        download = "medium";
        server = "mynix";
      };

      power-profiles-daemon = {
        enable = true;
        auto = true;
      };
    };

    settings = {
      #// system76.enable = true;
    };
  };

  #!! Rebuild offline - drastically increases initial download and resulting closure size
  #?? Alternative: nixos-rebuild --no-substitute
  # https://discourse.nixos.org/t/rebuild-nixos-offline/3679
  #// system.includeBuildDependencies = true;
}
