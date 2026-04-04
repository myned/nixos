{
  config,
  lib,
  ...
}:
with lib; {
  custom = {
    profile = "core";
    server = true;

    programs = {
      fastfetch.greet = true;
    };

    arion = {
      enable = true;
      boot = true;
      #// adguardhome.enable = true;
      beszel.enable = true;
      beszel.server = true;
      #// coturn.enable = true;
      #// gatus.enable = true;
      #// grafana.enable = true;
      #// headscale.enable = true;
      #// kener.enable = true;
      #// livekit.enable = true;
      #// netdata.enable = true;
      ntfy.enable = true;
      #// openspeedtest.enable = true;
      ovenmediaengine.enable = true;
      #// portainer.enable = true;
      #// portainer.server = true;
      #// rustdesk.enable = true;
      #// statping.enable = true;
      #// syncthing.enable = true;
      #// syncthing.server = true;
      #// uptimekuma.enable = true;
    };

    containers = {
      enable = true;
      blocky.enable = true;
      livekit.enable = true;
      site.enable = true;
      uptimekuma.enable = true;
      vintagestory.enable = true;
    };

    services = {
      # TODO: Revisit when addons are supported
      # https://github.com/NixOS/nixpkgs/issues/408699
      #// cockpit.enable = true;
      sshd.enable = true;

      borgmatic = {
        enable = true;
        repositories = ["ssh://ylnb45tz@ylnb45tz.repo.borgbase.com/./repo"];
        sources = ["/home" "/srv"];
      };

      caddy = {
        enable = true;
        enableCinny = true;
        enableElementWeb = true;
        enableFluffyChatWeb = true;
        enableSynapseAdmin = true;
        importEnvironment = true;
        srvKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBYspWeL1pBqX7Bl2pK/vnBE/B7VA93SYgz6O9YlrgNl";
        globalConfig = readFile ./caddy/global.caddyfile;
        extraConfig = ''
          import ${./caddy/snippets}/*.caddyfile
          import ${./caddy/sites}/*.caddyfile
        '';
      };
    };
  };
}
