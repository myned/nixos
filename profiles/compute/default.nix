{config, ...}: {
  custom = {
    profile = "compute";
    server = true;

    programs = {
      fastfetch.greet = true;
    };

    arion = {
      enable = true;
      boot = true;
      beszel.enable = true;
      forgejo.enable = true;
      #// portainer.enable = true;
    };

    services = {
      borgmatic = {
        enable = true;
        repositories = ["ssh://z0jt1u64@z0jt1u64.repo.borgbase.com/./repo"];
        sources = ["/home"];
      };
    };
  };
}
