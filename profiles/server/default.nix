{config, ...}: {
  custom = {
    profile = "server";

    programs = {
      fastfetch.greet = true;
    };

    containers = {
      enable = true;
      boot = true;
      actualbudget.enable = true;
      affine.enable = true;
      beszel.enable = true;
      #// conduwuit.enable = true;
      #// dashdot.enable = true;
      #// directus.enable = true;
      forgejo.enable = true;
      forgejo.server = true;
      foundryvtt.enable = true;
      #// freshrss.enable = true;
      #// ghost.enable = true;
      kasm.enable = true;
      mastodon.enable = true;
      #// miniflux.enable = true;
      mullvad.enable = true;
      #// netbox.enable = true;
      netdata.enable = true;
      #// nextcloud.enable = true;
      nextcloudaio.enable = true;
      opengist.enable = true;
      openwebui.enable = true;
      #// oryx.enable = true;
      ovenmediaengine.enable = true;
      #// owncast.enable = true;
      #// passbolt.enable = true;
      #// piped.enable = true;
      portainer.enable = true;
      #// rconfig.enable = true;
      redlib.enable = true;
      #// searxng.enable = true;
      #// srs.enable = true;
      stremio.enable = true;
      synapse.enable = true;
      synapseadmin.enable = true;
      vaultwarden.enable = true;
      #// wikijs.enable = true;

      jellyfin = {
        enable = true;
        dataDir = "/mnt/local/jellyfin";
      };
    };

    services = {
      borgmatic = {
        enable = true;
        repositories = ["ssh://ysrll00y@ysrll00y.repo.borgbase.com/./repo"];

        sources = [
          config.custom.containers.directory
          "/home"
          "/mnt/local"
        ];
      };

      syncthing = {
        enable = true;
        mount = "mnt-local.mount";
        path = "/mnt/local/syncthing";
        type = "receiveonly";
      };
    };
  };
}
