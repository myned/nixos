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
      dashdot.enable = true;
      forgejo.enable = true;
      foundryvtt.enable = true;
      #// freshrss.enable = true;
      grafana.enable = true;
      #// headscale.enable = true;
      mastodon.enable = true;
      miniflux.enable = true;
      netbox.enable = true;
      #// netdata.enable = true;
      #// nextcloud.enable = true;
      nextcloudaio.enable = true;
      ntfy.enable = true;
      openwebui.enable = true;
      oryx.enable = true;
      #// owncast.enable = true;
      #// portainer.enable = true;
      #// rconfig.enable = true;
      redlib.enable = true;
      searxng.enable = true;
      #// stremio.enable = true;
      synapse.enable = true;
      synapseadmin.enable = true;
      uptimekuma.enable = true;
      vaultwarden.enable = true;
      wikijs.enable = true;
    };

    services = {
      caddy.enable = true;
      #// modufur.enable = true;
      prometheus.enable = true;
      #// tailscale.cert = true;

      borgmatic = {
        enable = true;

        sources = [
          config.custom.containers.directory
          "/home"
          "/mnt/local"
          "/srv"
          #// "/var/lib/matrix-conduit"
        ];

        repositories = [
          {
            path = "ssh://ysrll00y@ysrll00y.repo.borgbase.com/./repo";
            label = "server";
          }
        ];
      };

      # TODO: Setup netdata
      # netdata = {
      #   enable = true;
      #   parent = true;
      # };

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
