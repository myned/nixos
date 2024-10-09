# WARNING

## This configuration is not meant for public usage

# Install

## Remote (with NixOS Anywhere)

1. Clone this repository

```sh
git clone https://github.com/myned/nixos
```

2. Enable [Flakes](https://wiki.nixos.org/wiki/Flakes)

3. Boot from NixOS [minimal installer](https://nixos.org/download.html#nixos-iso)

4. Create machine-specific modules in `machines/MACHINE/`

a. Machine configuration and hostname in `default.nix`

```nix
{ custom.hostname = "MACHINE"; }
```

b. [Disko](https://github.com/nix-community/disko) layout in `disko.nix`

```sh
# Verify /dev identifier on machine
lsblk

# Verify EFI/BIOS firmware on machine
[ -d /sys/firmware/efi/efivars ] && echo "UEFI" || echo "BIOS"
```

c. Generated hardware configuration in `hardware-configuration.nix`

```sh
nixos-generate-config --show-hardware-config --no-filesystems --root /mnt
```

5. Choose profile and add machine-specific modules to `flake.in.nix`

```nix
MACHINE = BRANCH "ARCHITECTURE" [ ./profiles/PROFILE ./machines/MACHINE ];
```

6. Generate and lock `flake.nix` with [flakegen](https://github.com/jorsn/flakegen)

```sh
cd nixos
git add .
nix run .#genflake flake.nix
nix flake lock
```

7. Generate machine SSH key and rekey agenix secrets with added public key

```sh
mkdir -p tmp/etc/ssh/
ssh-keygen -f tmp/etc/ssh/id_ed25519 -N '' -C root@MACHINE
cd secrets
agenix -r
```

8. Add user SSH key to root authorized_keys on machine

```sh
# On host
cat ~/.ssh/id_ed25519.pub | wl-copy
```

```sh
# On machine
sudo mkdir /root/.ssh/
sudo nano /root/.ssh/authorized_keys
```

9. Execute [NixOS Anywhere](https://github.com/nix-community/nixos-anywhere)

```sh
nixos-anywhere --extra-files tmp --flake .#MACHINE root@IP
```

10. Shutdown, detach ISO, and reboot

11. Remove temporary files

```sh
rm -r tmp
```
