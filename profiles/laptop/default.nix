{
  custom = {
    full = true;
    profile = "desktop"; # Inherit desktop profile
    desktop = "niri";

    services = {
      #// auto-cpufreq.enable = true;

      power-profiles-daemon = {
        enable = true;
        auto = true;
      };
    };
  };

  #!! Rebuild offline - drastically increases initial download and resulting closure size
  #?? Alternative: nixos-rebuild --no-substitute
  # https://discourse.nixos.org/t/rebuild-nixos-offline/3679
  #// system.includeBuildDependencies = true;
}
