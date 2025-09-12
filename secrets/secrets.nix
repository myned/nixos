let
  # https://wiki.nixos.org/wiki/Agenix
  # https://github.com/ryantm/agenix
  #?? cd secrets/
  #?? agenix --edit file.age
  #?? agenix --rekey
  # Users that imperatively encrypt age files
  #!! Imperative client key generation
  #?? ssh-keygen -f ~/.ssh/id_ed25519 -N ''
  users = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKcKnHQnd75sTQa8EchKbanEb8w26g53TY9QAp5NZxUa myned@mynix"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM/IWN11WX5MbDNwgD1LA1U1iv31yNjoS44Hzgf4xe7d myned@myork"
  ];

  # Machines that decrypt age files during activation
  #!! Imperative host key generation without sshd service
  #?? sudo ssh-keygen -f /etc/ssh/id_ed25519 -N ''
  myeck = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJh8nTTOUsmKQa7zIftN2k8BgbQbXENc98KSJIyorMON root@myeck";
  myeye = "";
  mynix = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBKKqfRtKZ+8Qm9DjurAJ8Ob4IZjAWZQjNGQXgQVRr8M root@mynix";
  myore = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBn/6eJvcDsjphoqFrGlPqMUf3wya3LYgFf2RoutpRVu root@myore";
  myork = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBsJT7qVAarFGBE7i2DJfMsRlY0T95ZPRAG9WNXejmgc root@myork";
  myosh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIENq879QYYHnC8542PB+nzrU0SyWiAEkzWhTFrZxJ5n6 root@myosh";
  mypi3 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHfJT4DX8pakYra4CDSTksFG1RCPkuoGt2YC3MNF2H1f root@mypi3";

  common = [myeck myeye mynix myore myork myosh mypi3];

  key = key: {publicKeys = users ++ [key];};
  keys = keys: {publicKeys = users ++ keys;};
in {
  "common/geoclue2/geolocation" = keys common;
  "common/nix/access-tokens.conf" = keys common;
  "common/ntfy/token" = keys common;
  "common/tailscale/container.env" = keys common;

  "myeck/users/myned.pass" = key myeck;
  "myeck/users/root.pass" = key myeck;

  "myeye/borgmatic/borgbase" = key myeye;
  "myeye/users/myned.pass" = key myeye;
  "myeye/users/root.pass" = key myeye;

  "mynix/users/myned.pass" = key mynix;
  "mynix/users/root.pass" = key mynix;
  "mynix/vm/myndows.pass" = key mynix;

  "myore/borgmatic/borgbase" = key myore;
  "myore/caddy/.env" = key myore;
  "myore/caddy/Caddyfile" = key myore;
  "myore/coturn/coturn.conf" = key myore;
  "myore/headscale/config.yaml" = key myore;
  "myore/headscale/policy.hujson" = key myore;
  "myore/headscale/ui.yaml" = key myore;
  "myore/kener/.env" = key myore;
  "myore/kener/db.env" = key myore;
  "myore/netdata/parent.conf" = key myore;
  "myore/users/myned.pass" = key myore;
  "myore/users/root.pass" = key myore;

  "myork/users/myned.pass" = key myork;
  "myork/users/root.pass" = key myork;
  "myork/vm/myndows.pass" = key myork;

  "myosh/affine/.env" = key myosh;
  "myosh/affine/db.env" = key myosh;
  "myosh/borgmatic/borgbase" = key myosh;
  "myosh/conduwuit/conduwuit.toml" = key myosh;
  "myosh/directus/.env" = key myosh;
  "myosh/forgejo/.env" = key myosh;
  "myosh/forgejo/db.env" = key myosh;
  "myosh/foundryvtt/.env" = key myosh;
  "myosh/ghost/.env" = key myosh;
  "myosh/ghost/db.env" = key myosh;
  "myosh/jellyfin/soularr.ini" = key myosh;
  "myosh/jellyfin/slskd.env" = key myosh;
  "myosh/jellyfin/tailscale.env" = key myosh;
  "myosh/mastodon/.env" = key myosh;
  "myosh/mastodon/db.env" = key myosh;
  "myosh/matrix-conduit/conduwuit.toml" = key myosh;
  "myosh/miniflux/.env" = key myosh;
  "myosh/miniflux/db.env" = key myosh;
  "myosh/mullvad/gluetun.env" = key myosh;
  "myosh/mullvad/wireguard.conf" = key myosh;
  "myosh/netbox/.env" = key myosh;
  "myosh/netbox/cache.env" = key myosh;
  "myosh/netbox/db.env" = key myosh;
  "myosh/nextcloud/.env" = key myosh;
  "myosh/nextcloud/db.env" = key myosh;
  "myosh/oryx/.env" = key myosh;
  "myosh/passbolt/.env" = key myosh;
  "myosh/passbolt/db.env" = key myosh;
  "myosh/rconfig/.env" = key myosh;
  "myosh/rconfig/db.env" = key myosh;
  "myosh/searxng/.env" = key myosh;
  "myosh/synapse/db.env" = key myosh;
  "myosh/synapse/homeserver.yaml" = key myosh;
  "myosh/users/myned.pass" = key myosh;
  "myosh/users/root.pass" = key myosh;
  "myosh/vaultwarden/.env" = key myosh;
  "myosh/wikijs/.env" = key myosh;
  "myosh/wikijs/db.env" = key myosh;

  "mypi3/borgmatic/borgbase" = key mypi3;
  "mypi3/create_ap/passphrase" = key mypi3;
  "mypi3/create_ap/ssid" = key mypi3;
  "mypi3/netdata/child.conf" = key mypi3;
  "mypi3/users/myned.pass" = key mypi3;
  "mypi3/users/root.pass" = key mypi3;
}
