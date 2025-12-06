{config, ...}: {
  custom = {
    profile = "sbc";

    programs = {
      fastfetch.greet = true;
    };

    containers = {
      enable = true;
      boot = true;
      beszel.enable = true;
      homeassistant.enable = true;
      #// netdata.enable = true;
      #// portainer.enable = true;
    };

    services = {
      borgmatic = {
        enable = true;
        repositories = ["ssh://h1m9k594@h1m9k594.repo.borgbase.com/./repo"];
        sources = [config.custom.containers.directory];
      };
    };

    settings = {
      networking = {
        networkmanager = true;
        wifi = true;
      };
    };
  };
}
