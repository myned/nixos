{
  custom = {
    profile = "server";
    programs.fastfetch.greet = true;

    services = {
      caddy.enable = true;
      matrix-conduit.enable = true;
      #// modufur.enable = true;
      tailscale.cert = true;

      borgmatic = {
        enable = true;
        sources = [
          "/containers"
          "/home"
          "/mnt/remote"
          "/srv"
        ];

        repositories = [
          {
            path = "ssh://n882bnik@n882bnik.repo.borgbase.com/./repo";
            label = "myarm";
          }
        ];
      };

      # netdata = {
      #   enable = true;
      #   parent = true;
      # };

      syncthing = {
        enable = true;
        configDir = "/var/lib/syncthing";
        dataDir = "/mnt/remote/syncthing";
        ignorePerms = true; # Mount permissions are forced
        mount = "mnt-remote-syncthing.mount";
        type = "receiveonly";
        user = "syncthing";
        group = "syncthing";
      };
    };

    settings = {
      boot.systemd-boot = true;
      mounts.enable = true;
      users.myned.linger = true;

      containers = {
        enable = true;
        boot = true;
        actualbudget.enable = true;
        coturn.enable = true;
        forgejo.enable = true;
        foundryvtt.enable = true;
        #// headscale.enable = true;
        mastodon.enable = true;
        nextcloud.enable = true;
        redlib.enable = true;
        searxng.enable = true;
      };
    };
  };
}
