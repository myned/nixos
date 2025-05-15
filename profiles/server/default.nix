{config, ...}: {
  custom = {
    profile = "server";

    programs = {
      fastfetch.greet = true;
      ghostty.minimal = true;
    };

    containers = {
      enable = true;
      boot = true;

      actualbudget.enable = true;
      adguardhome.enable = true;
      beszel.enable = true;
      beszel.server = true;
      #// conduwuit.enable = true;
      coturn.enable = true;
      #// dashdot.enable = true;
      #// directus.enable = true;
      forgejo.enable = true;
      forgejo.server = true;
      foundryvtt.enable = true;
      #// freshrss.enable = true;
      #// ghost.enable = true;
      grafana.enable = true;
      #// headscale.enable = true;
      kener.enable = true;
      mastodon.enable = true;
      miniflux.enable = true;
      #// netbox.enable = true;
      #// netdata.enable = true;
      #// nextcloud.enable = true;
      nextcloudaio.enable = true;
      ntfy.enable = true;
      opengist.enable = true;
      openwebui.enable = true;
      oryx.enable = true;
      #// owncast.enable = true;
      #// passbolt.enable = true;
      portainer.enable = true;
      portainer.server = true;
      #// rconfig.enable = true;
      redlib.enable = true;
      #// searxng.enable = true;
      stremio.enable = true;
      synapse.enable = true;
      synapseadmin.enable = true;
      #// uptimekuma.enable = true;
      vaultwarden.enable = true;
      #// wikijs.enable = true;

      caddy = {
        enable = true;
        public-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBYspWeL1pBqX7Bl2pK/vnBE/B7VA93SYgz6O9YlrgNl";
      };

      jellyfin = {
        enable = true;
        dataDir = "/mnt/local/jellyfin";
      };
    };

    services = {
      prometheus.enable = true;
      sshd.enable = true;

      borgmatic = {
        enable = true;

        sources = [
          config.custom.containers.directory
          "/home"
          "/mnt/local"
          "/srv"
        ];

        repositories = [
          {
            path = "ssh://ysrll00y@ysrll00y.repo.borgbase.com/./repo";
            label = "server";
          }
        ];
      };

      syncthing = {
        enable = true;
        configDir = "/var/lib/syncthing";
        dataDir = "/mnt/local/syncthing";
        mount = "mnt-local.mount";
        type = "receiveonly";
        user = "syncthing";
        group = "syncthing";
      };
    };
  };
}
