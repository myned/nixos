{config, ...}: {
  custom = {
    full = true;
    profile = "laptop";
    desktop = "niri";

    arion = {
      enable = true;
      user = config.custom.username;
    };

    services = {
      #// auto-cpufreq.enable = true;
      colord.enable = true;
      ollama.download = ["low" "uncensored"];
      tuned.enable = true;
      #// wluma.enable = true;

      # power-profiles-daemon = {
      #   enable = true;
      #   auto = true;
      # };
    };

    settings = {
      #// system76.enable = true;
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
