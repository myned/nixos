{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.vm;
in {
  options.custom.settings.vm = {
    enable = mkOption {default = false;};
    libvirt = mkOption {default = true;};
    virtualbox = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    virtualisation = {
      # https://wiki.nixos.org/wiki/Libvirt
      # https://libvirt.org
      libvirtd = mkIf cfg.libvirt {
        enable = true;
        onBoot = "ignore";
        onShutdown = "shutdown";

        qemu = {
          swtpm.enable = true; # TPM emulation

          # Build OVMF with Windows 11 support
          ovmf.packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            })
            .fd
          ];
        };

        # Guest hostname resolution
        # https://libvirt.org/nss.html
        #!! Requires DHCP, preferably without lease expiry
        # https://libvirt.org/formatnetwork.html#addressing
        #?? sudo virsh net-dhcp-leases NETWORK
        #?? <range ...>
        #??   <lease expiry="0"/>
        #?? </range>
        nss = {
          enable = true;
          enableGuest = true;
        };

        # Attempt to synchronize time with host on resume
        # https://libvirt.org/manpages/libvirt-guests.html
        #!! Windows Time service must be started on Windows guest
        #?? sudo virsh domtime DOMAIN --sync
        extraConfig = ''
          SYNC_TIME=1
        '';
      };

      # https://wiki.nixos.org/wiki/VirtualBox
      # https://www.virtualbox.org
      virtualbox.host = mkIf cfg.virtualbox {
        enable = true;
        enableExtensionPack = true;
      };
    };

    # https://github.com/virt-manager/virt-manager
    programs.virt-manager.enable = cfg.libvirt;

    # https://libvirt.org/uri.html#default-uri-choice
    environment.sessionVariables.LIBVIRT_DEFAULT_URI = mkIf cfg.libvirt "qemu:///system";

    users.users.${config.custom.username}.extraGroups =
      lib.optionals cfg.libvirt ["libvirtd"]
      ++ lib.optionals cfg.virtualbox ["vboxusers"];

    systemd = mkIf cfg.libvirt {
      # Fix resume messages polluting tty
      services.libvirt-guests.serviceConfig.StandardOutput = "journal";

      tmpfiles.rules = let
        firmware = pkgs.runCommandLocal "qemu-firmware" {} ''
          mkdir $out
          cp ${pkgs.qemu}/share/qemu/firmware/*.json $out
          substituteInPlace $out/*.json --replace ${pkgs.qemu} /run/current-system/sw
        '';
      in [
        # HACK: Fix libvirt not automatically locating firmware
        # https://github.com/NixOS/nixpkgs/issues/115996#issuecomment-2224296279
        # https://libvirt.org/formatdomain.html#bios-bootloader
        "L+ /var/lib/qemu/firmware - - - - ${firmware}"

        # HACK: Manually link image to default directory
        "L+ /var/lib/libvirt/images/virtio-win.iso - - - - ${inputs.virtio-win}"
      ];
    };
  };
}
