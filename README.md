# Install

## Remote (with [nixos-anywhere](https://github.com/nix-community/nixos-anywhere))

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
nixos-generate-config --show-hardware-config
```

5. Choose or create a profile in `profiles/<profile>/default.nix` and add the machine to `flake.in.nix`

```nix
{
  ...
  <machine> = nixos "<architecture>" [ ./profiles/<profile> ./machines/<machine> ];
  ...
}
```

6. Generate and lock `flake.nix` with [flakegen](https://github.com/jorsn/flakegen)

```sh
cd nixos
git add .
nix run .#genflake flake.nix
nix flake lock
```

7. Generate machine SSH key and copy to clipboard

```sh
mkdir -p tmp/etc/ssh/
ssh-keygen -f tmp/etc/ssh/id_ed25519 -N '' -C root@<machine>
cat tmp/etc/ssh/id_ed25519.pub | wl-copy -n
```

8. Rekey agenix secrets after adding public key to `secrets/secrets.nix`

```sh
cd secrets/
agenix -r
cd -
```

9. If encrypting with LUKS, write the passphrase to `/tmp/secret.key` and mount the key device containing the keyfile if `custom.settings.storage.key.enable = true`

```sh
# On machine
echo -n '<passphrase>' > /tmp/secret.key
sudo mkdir -p /key
sudo mount /dev/<device> /key
```

10. Create a temporary password for the root user (or use SSH keys)

```sh
# On machine
sudo passwd
```

11. Execute nixos-anywhere to install

```sh
nixos-anywhere --extra-files tmp/ --flake .#<machine> root@<ip>
```

12. Reboot machine

13. Remove temporary files

```sh
rm -r tmp/
```
