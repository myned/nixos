{config, ...}: {
  custom = {
    full = true;
    profile = "laptop";
    desktop = "niri";

    services = {
      #// auto-cpufreq.enable = true;
      #// colord.enable = true;
      ollama.download = ["potato" "medium"];
      power-profiles-daemon.enable = true;
      power-profiles-daemon.auto = true;
      #// tuned.enable = true;
      #// wluma.enable = true;
    };

    vms = {
      enable = true;
      myndows.enable = true;
    };
  };

  #!! Rebuild offline - drastically increases initial download and resulting closure size
  #?? Alternative: nixos-rebuild --no-substitute
  # https://discourse.nixos.org/t/rebuild-nixos-offline/3679
  #// system.includeBuildDependencies = true;
}
