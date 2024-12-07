{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  virsh = "${config.virtualisation.libvirtd.package}/bin/virsh";

  cfg = config.custom.settings.vm;
in {
  options.custom.settings.vm = {
    enable = mkOption {default = false;};
    libvirt = mkOption {default = true;};
    virtualbox = mkOption {default = false;};

    passthrough = {
      enable = mkOption {default = false;};
      driver = mkOption {default = null;}; #?? lspci -k
      guest = mkOption {default = null;}; #?? virsh list --all
      id = mkOption {default = null;}; #?? lspci -nn
      init = mkOption {default = false;};
      intel = mkOption {default = false;};
      node = mkOption {default = null;}; #?? virsh nodedev-list
    };
  };

  config = mkIf cfg.enable {
    virtualisation = {
      # https://wiki.nixos.org/wiki/Libvirt
      # https://libvirt.org
      libvirtd = mkIf cfg.libvirt {
        enable = true;
        onBoot = "ignore";
        onShutdown = "shutdown";

        # https://libvirt.org/hooks.html
        hooks.qemu = {
          # Attach/detach GPU for passthrough
          passthrough = mkIf cfg.passthrough.enable (pkgs.writeShellScript "passthrough" ''
            if [[ "$1" == "${cfg.passthrough.guest}" ]]; then
              case "$2" in
                prepare)
                  ${virsh} nodedev-detach ${cfg.passthrough.node}
                  ;;
                release)
                  ${virsh} nodedev-reattach ${cfg.passthrough.node}
                  ;;
                *)
                  exit
                  ;;
              esac
            fi
          '');
        };

        qemu = {
          swtpm.enable = true; # TPM emulation

          # BUG: Windows requires global mountpoint for some applications (\\.\*: instead of *:)
          # https://github.com/virtio-win/kvm-guest-drivers-windows/issues/950
          # https://virtio-win.github.io/Knowledge-Base/Virtiofs:-Shared-file-system
          #// vhostUserPackages = with pkgs; [virtiofsd]; # virtiofs support

          # Build OVMF with Windows 11 support
          ovmf.packages = with pkgs; [
            (OVMF.override {
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
      services = {
        # Fix resume messages polluting tty
        libvirt-guests.serviceConfig = {
          StandardOutput = "journal";
        };
      };

      tmpfiles.settings."10-vm" = {
        # HACK: Manually link image to default directory
        "/var/lib/libvirt/images/virtio-win.iso" = {
          "L+" = {
            argument = "${inputs.virtio-win}";
          };
        };

        # HACK: Fix libvirt not automatically locating firmware
        # https://github.com/NixOS/nixpkgs/issues/115996#issuecomment-2224296279
        # https://libvirt.org/formatdomain.html#bios-bootloader
        "/var/lib/qemu/firmware" = {
          "L+" = {
            argument = "${pkgs.runCommandLocal "qemu-firmware" {} ''
              mkdir $out
              cp ${pkgs.qemu}/share/qemu/firmware/*.json $out
              substituteInPlace $out/*.json --replace ${pkgs.qemu} /run/current-system/sw
            ''}";
          };
        };
      };
    };

    boot = mkIf cfg.passthrough.enable {
      # https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Isolating_the_GPU
      blacklistedKernelModules = mkIf cfg.passthrough.init [cfg.passthrough.driver];

      # https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Enabling_IOMMU
      kernelParams = mkIf cfg.passthrough.intel ["intel_iommu=on"];
    };
  };
}
