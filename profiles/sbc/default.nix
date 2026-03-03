{config, ...}: {
  custom = {
    profile = "sbc";
    server = true;

    programs = {
      fastfetch.greet = true;
    };

    arion = {
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
