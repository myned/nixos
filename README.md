# WARNING

## This configuration is not meant for public usage

# Install

## Remote (with NixOS Anywhere)

1. Clone this repository

   ```sh
   git clone https://github.com/Myned/nixos
   ```

2. Enable [Flakes](https://wiki.nixos.org/wiki/Flakes)

3. Boot from NixOS [minimal installer](https://nixos.org/download.html#nixos-iso)

4. Create machine-specific modules in `machines/MACHINE/`

   b. Machine configuration and hostname in `default.nix`

   ```nix
   { custom.hostname = "MACHINE"; }
   ```

   c. [Disko](https://github.com/nix-community/disko) layout in `disko.nix`

   ```sh
   # Verify /dev identifier on machine
   lsblk

   # Verify EFI/BIOS firmware on machine
   [ -d /sys/firmware/efi/efivars ] && echo "UEFI" || echo "BIOS"
   ```

   d. Generated hardware configuration in `hardware-configuration.nix`

   ```sh
   nixos-generate-config --show-hardware-config --no-filesystems --root /mnt
   ```

5. Choose profile and add machine-specific modules to `flake.in.nix`

   ```nix
   MACHINE = BRANCH [ ./profiles/PROFILE ./machines/MACHINE ];
   ```

6. Generate `flake.nix` with [flakegen](https://github.com/jorsn/flakegen)

   ```sh
   git add .
   nix run .#genflake flake.nix
   nix flake lock
   ```

7. Copy host public SSH key to root on machine

   ```sh
   # On machine
   sudo passwd root
   ```

   ```sh
   # On host
   ssh-copy-id root@MACHINE
   ```

8. Test and execute [NixOS Anywhere](https://github.com/nix-community/nixos-anywhere)

   ```sh
   nixos-anywhere --vm-test -f .#MACHINE root@IP
   nixos-anywhere -f .#MACHINE root@IP
   ```

9. Shutdown, detach ISO, and reboot
