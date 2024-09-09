# Install

## Remote (with NixOS Anywhere)

1. Clone this repository

   ```sh
   git clone https://github.com/Myned/nixos
   ```

2. Enable [Flakes](https://wiki.nixos.org/wiki/Flakes)

3. Boot from NixOS [minimal installer](https://nixos.org/download.html#nixos-iso)

4. Create machine-specific modules in `machines/MACHINE/`

   a. If [Home Manager](https://github.com/nix-community/home-manager), home configuration in `home.nix`

   b. System configuration and hostname in `system.nix`

   ```nix
   { networking.hostName = "MACHINE"; }
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

   e. Import modules in `default.nix`

5. Choose profile and add machine-specific modules to `flake.in.nix`

   ```nix
   MACHINE = linux [ ./profiles/PROFILE ./machines/MACHINE ];
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

## Local (with script)

1. Clone repository using personal access token

   ```sh
   git clone https://TOKEN@github.com/Myned/nixos /tmp/nixos
   ```

2. Go to repository directory

   ```sh
   cd /tmp/nixos
   ```

3. Check disk layout

   ```sh
   lsblk
   ```

4. Modify disko layout to match hardware

   ```sh
   nano machine/MACHINE/disko.nix
   ```

5. Execute install script

   ```sh
   sudo nix --experimental-features 'nix-command flakes' run nixpkgs#fish -- install.fish
   ```

6. Optionally shred personal access token

   ```sh
   shred -zu github.token
   ```
