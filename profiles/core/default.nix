{config, ...}: {
  custom = {
    profile = "core";

    programs = {
      fastfetch.greet = true;
    };

    containers = {
      enable = true;
      boot = true;
      adguardhome.enable = true;
      beszel.enable = true;
      beszel.server = true;
      coturn.enable = true;
      #// grafana.enable = true;
      #// headscale.enable = true;
      kener.enable = true;
      #// netdata.enable = true;
      ntfy.enable = true;
      openspeedtest.enable = true;
      portainer.enable = true;
      portainer.server = true;
      rustdesk.enable = true;
      statping.enable = true;
      #// syncthing.enable = true;
      #// syncthing.server = true;
      uptimekuma.enable = true;

      caddy = {
        enable = true;
        public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBYspWeL1pBqX7Bl2pK/vnBE/B7VA93SYgz6O9YlrgNl";
      };
    };

    services = {
      # TODO: Revisit when addons are supported
      # https://github.com/NixOS/nixpkgs/issues/408699
      #// cockpit.enable = true;

      borgmatic = {
        enable = true;
        repositories = ["ssh://ylnb45tz@ylnb45tz.repo.borgbase.com/./repo"];

        sources = [
          config.custom.containers.directory
          "/home"
          "/srv"
        ];
      };
    };
  };
}
