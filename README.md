# About

Monorepo for @myned's personal NixOS configuration and partial homelab infrastructure

# Caveats

Security considerations are practically lax, but always open for improvement:

- Secrets handled via agenix, inheriting its [threat model](https://github.com/ryantm/agenix?tab=readme-ov-file#threat-modelwarnings)
- Storage module supports LUKS encryption at rest via disko and systemd initrd
- Containers attempt to be compatible with rootless docker
- Prioritizes usability over hardening (ex. some home-manager modules apply to the root user)
- Assumes a single-user machine plus root

Various tools are underdocumented prerequisites:

- agenix (for secrets management)
- disko (for disk formatting and declaration)
- flakes (for reproducibility)
- genflake (for use of normal nix in flake.in.nix)
- home-manager (for user modules)
- nixos-anywhere (for remote installation)
- nixos-hardware (for hardware quirks)
- stylix (for interactive theming)
- tailscale (for mesh communication)

...combined with some nix abstractions used by custom modules:

- machines (hardware-specific options identified by hostname)
- profiles (shared options between machines identified by purpose)

# Install

General instructions for how to use this configuration, may not include all requirements

1. Clone this repository

```sh
git clone https://git.bjork.tech/myned/nixos
```

2. Boot from the [NixOS installer](https://nixos.org/download.html#nixos-iso)

3. Add machine-specific configuration to `machines/<machine>/default.nix`

```nix
{
  ...
  imports = [
    ./hardware-configuration.nix
  ];

  custom = {
    hostname = "<machine>";

    settings = {
      boot.systemd-boot.enable = true;
      storage.root.device = "/dev/disk/by-*/<disk>"
    }
  };
  ...
}
```

4. Add generated hardware configuration to `machines/<machine>/hardware-configuration.nix`

```sh
# On machine
nixos-generate-config --show-hardware-config --no-filesystems
```

5. Choose or create a profile in `profiles/<profile>/default.nix`

```nix
{
  ...
  custom = {
    profile = "<profile>";
  };
  ...
}
```

6. Add the machine to `flake.in.nix`

```nix
{
  ...
  <machine> = nixos "<architecture>" [ ./profiles/<profile> ./machines/<machine> ];
  ...
}
```

7. Stage git files and lock `flake.nix`

```sh
cd nixos
git add .
nix flake lock
```

8. Generate machine SSH key and copy public key to clipboard

```sh
mkdir -p tmp/etc/ssh/
ssh-keygen -f tmp/etc/ssh/id_ed25519 -N '' -C root@<machine>
cat tmp/etc/ssh/id_ed25519.pub | wl-copy -n
```

9. Add public key to `secrets/secrets.nix`

```nix
{
  ...
  <machine> = "<ssh public key>";
  ...
}
```

10. Rekey agenix secrets

```sh
cd secrets/
agenix -r
cd -
```

11. Add encrypted password declarations to `secrets/secrets.nix`

```nix
{
  ...
  "<machine>/users/<username>.pass" = machine <machine>;
  "<machine>/users/root.pass" = machine <machine>;
  ...
}
```

12. Create hashed password files with agenix

```sh
cd secrets/
mkpasswd | wl-copy
agenix -e <machine>/users/<username>.pass
mkpasswd | wl-copy
agenix -e <machine>/users/root.pass
cd -
```

13. If encrypting with LUKS, write the passphrase to `/tmp/secret.key` and mount the key device containing the keyfile if `custom.settings.storage.key.enable = true`

```sh
# On machine
echo -n '<passphrase>' > /tmp/secret.key
sudo mkdir -p /key
sudo mount /dev/disk/by-*/<device> /key
```

14. Create a temporary password for the nixos user (or use SSH keys)

```sh
# On machine
passwd
```

15. Execute [nixos-anywhere](https://github.com/nix-community/nixos-anywhere) to install remotely

```sh
nixos-anywhere --flake .#<machine> nixos@<ip> --extra-files tmp/
```

16. Remove temporary files

```sh
rm -r tmp/
```

# Deploy

Subsequent deployment of configuration changes, implies `/etc/nixos` as repo location

## Local builds

```sh
sudo nixos-rebuild switch
```

## Remote builds

```sh
nixos-rebuild switch --flake .#<machine> --target-host root@<ip>
```
