{
  custom = {
    full = true;
    profile = "desktop"; # Inherit desktop
    services.auto-cpufreq.enable = true;
  };

  #!! Rebuild offline - drastically increases initial download and resulting closure size
  # https://discourse.nixos.org/t/rebuild-nixos-offline/3679
  system.includeBuildDependencies = true;
}
