{
  custom = {
    profile = "sbc";
    programs.fastfetch.greet = true;

    services = {
      tailscale.cert = true;

      borgmatic = {
        enable = true;
        sources = ["/containers"];

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

      containers = {
        enable = true;
        boot = true;
        homeassistant.enable = true;
      };
    };
  };
}
