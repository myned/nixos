{
  custom = {
    full = true;
    profile = "desktop"; # Inherit desktop profile

    services = {
      power-profiles-daemon.auto = true;
    };
  };

  #!! Rebuild offline - drastically increases initial download and resulting closure size
  #?? Alternative: nixos-rebuild --no-substitute
  # https://discourse.nixos.org/t/rebuild-nixos-offline/3679
  #// system.includeBuildDependencies = true;
}
