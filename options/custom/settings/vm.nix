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
      blacklist = mkOption {default = false;};
      guest = mkOption {default = null;}; #?? virsh list --all
    };
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
        owner = config.custom.username;
        group = config.users.users.${config.custom.username}.group;
      };
    in {
      "desktop/vm/myndows.pass" = secret "desktop/vm/myndows.pass";
    };

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
          passthrough = let
            #?? virsh nodedev-list
            node = replaceStrings ["-" ":" "."] ["_" "_" "_"] config.custom.settings.hardware.dgpu.node;
          in
            mkIf cfg.passthrough.enable (pkgs.writeShellScript "passthrough" ''
              if [[ "$1" == "${cfg.passthrough.guest}" ]]; then
                case "$2" in
                  prepare)
                    ${virsh} nodedev-detach ${node}
                    ;;
                  release)
                    ${virsh} nodedev-reattach ${node}
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

      # Allow unprivileged users to redirect USB devices
      spiceUSBRedirection.enable = cfg.libvirt;
    };

    # https://github.com/virt-manager/virt-manager
    programs.virt-manager.enable = cfg.libvirt;

    environment.sessionVariables =
      optionalAttrs cfg.libvirt {
        # https://libvirt.org/uri.html#default-uri-choice
        LIBVIRT_DEFAULT_URI = "qemu:///system";
      }
      // optionalAttrs (with cfg.passthrough; (enable && blacklist)) {
        # https://wiki.archlinux.org/title/PRIME#For_open_source_drivers_-_PRIME
        DRI_PRIME = replaceStrings [":" "."] ["_" "_"] config.custom.settings.hardware.igpu.node;
      };

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

      tmpfiles.settings.vm = {
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
      blacklistedKernelModules = optionals cfg.passthrough.blacklist [
        config.custom.settings.hardware.dgpu.driver
      ];

      initrd.kernelModules = optionals cfg.passthrough.blacklist [
        "vfio_pci"
        "vfio"
        "vfio_iommu_type1"
      ];

      extraModprobeConfig = let
        ids = concatStringsSep "," config.custom.settings.hardware.dgpu.ids;
      in
        optionalString cfg.passthrough.blacklist ''
          options vfio-pci ids=${ids}
        '';

      # https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF#Enabling_IOMMU
      kernelParams = optionals (config.custom.settings.hardware.cpu == "intel") [
        "intel_iommu=on"
      ];
    };
  };
}
