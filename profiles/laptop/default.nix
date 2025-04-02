{
  custom = {
    full = true;

    # FIXME: Use "laptop" profile
    profile = "desktop"; # Inherit desktop profile

    desktop = "niri";

    services = {
      auto-cpufreq.enable = true;

      ollama = {
        download = "medium";
        server = "mynix";
      };

      power-profiles-daemon = {
        #// enable = true;
        auto = true;
      };
    };
  };

  #!! Rebuild offline - drastically increases initial download and resulting closure size
  #?? Alternative: nixos-rebuild --no-substitute
  # https://discourse.nixos.org/t/rebuild-nixos-offline/3679
  #// system.includeBuildDependencies = true;
}
