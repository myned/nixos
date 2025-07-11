{config, ...}: {
  custom = {
    profile = "compute";

    programs = {
      fastfetch.greet = true;
    };

    containers = {
      enable = true;
      boot = true;
      beszel.enable = true;
      forgejo.enable = true;
      portainer.enable = true;
    };

    services = {
      borgmatic = {
        enable = true;
        repositories = ["ssh://z0jt1u64@z0jt1u64.repo.borgbase.com/./repo"];

        sources = [
          config.custom.containers.directory
          "/home"
        ];
      };
    };
  };
}
