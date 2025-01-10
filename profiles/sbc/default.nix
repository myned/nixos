{config, ...}: {
  custom = {
    profile = "sbc";

    programs = {
      fastfetch.greet = true;
      ghostty.minimal = true;
    };

    containers = {
      enable = true;
      boot = true;
      homeassistant.enable = true;
    };

    services = {
      #// tailscale.cert = true;

      borgmatic = {
        enable = true;
        sources = [config.custom.containers.directory];

        repositories = [
          {
            path = "ssh://h1m9k594@h1m9k594.repo.borgbase.com/./repo";
            label = "mypi3";
          }
        ];
      };

      # netdata = {
      #   enable = true;
      #   child = true;
      # };
    };

    settings = {
      boot.u-boot = true;
      networking.wifi = true;
    };
  };
}
