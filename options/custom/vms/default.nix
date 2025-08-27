{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  virsh = "${config.virtualisation.libvirtd.package}/bin/virsh";

  cfg = config.custom.vms;
in {
  options.custom.vms = {
    enable = mkOption {
      default = config.custom.full;
      description = "Whether to enable vms";
      example = true;
      type = types.bool;
    };

    virtualbox = {
      enable = mkOption {
        default = false;
        description = "Whether to enable virtualbox";
        example = true;
        type = types.bool;
      };
    };

    libvirt = {
      enable = mkOption {
        default = true;
        description = "Whether to enable libvirt";
        example = false;
        type = types.bool;
      };

      images = mkOption {
        default = [];
        description = "List of libvirt volumes to add to the default pool";
        type = with types; listOf attrs;

        example = [
          {
            name = "win11.qcow2";

            capacity = {
              count = 64;
              unit = "GiB";
            };
          }
        ];
      };
    };

    passthrough = {
      enable = mkEnableOption "passthrough";

      blacklist = mkOption {
        default = false;
        description = "Whether to blacklist the dgpu driver";
        example = true;
        type = types.bool;
      };

      guest = mkOption {
        default = null;
        description = "Name of the libvirt guest domain";
        example = "win11";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation = {
      # https://github.com/AshleyYakeley/NixVirt
      libvirt = mkIf cfg.libvirt.enable {
        enable = true;
        swtpm.enable = true;

        connections."qemu:///system" = {
          # https://github.com/AshleyYakeley/NixVirt?tab=readme-ov-file#libnetworkgetxml
          networks = with inputs.nixvirt.lib.network; [
            {
              active = true;
              restart = true;

              definition = writeXML (templates.bridge
                {
                  name = "default";
                  uuid = "19eb4048-0eb9-480a-85e8-58dbf88564e2";
                  bridge_name = "virbr0";
                  subnet_byte = 144; # 192.168.144.0/24
                });
            }

            {
              active = true;
              restart = true;

              definition = writeXML {
                name = "isolated";
                uuid = "22c377a2-e536-43c3-a9b7-21ed819642e1";
                bridge = {name = "virbr99";};

                # 192.168.255.0/24
                ip = {
                  address = "192.168.255.1";
                  netmask = "255.255.255.0";

                  dhcp.range = {
                    start = "192.168.255.2";
                    end = "192.168.255.254";
                  };
                };
              };
            }
          ];

          # https://github.com/AshleyYakeley/NixVirt?tab=readme-ov-file#libpoolgetxml
          pools = with inputs.nixvirt.lib.pool; [
            {
              active = true;
              restart = true;
              volumes = cfg.libvirt.images;

              definition = writeXML {
                name = "default";
                uuid = "d41533f2-fbc4-4d47-9e85-e31c82d87d10";
                type = "dir";
                target.path = "/var/lib/libvirt/images";
              };
            }

            {
              active = true;
              restart = true;

              definition = writeXML {
                name = "nvram";
                uuid = "bcbf8b1d-44c9-41d7-ba2c-b249dceb6ea1";
                type = "dir";
                target.path = "/var/lib/libvirt/qemu/nvram";
              };
            }

            {
              active = true;
              restart = true;

              definition = writeXML {
                name = "downloads";
                uuid = "9b05b1a8-de1f-4a95-ba84-612898b0cb5f";
                type = "dir";
                target.path = "${config.users.users.${config.custom.username}.home}/Downloads";
              };
            }

            {
              definition = writeXML {
                name = "ventoy";
                uuid = "877fa518-901e-4fda-a8c7-f01480ca4699";
                type = "dir";
                target.path = "/run/media/${config.custom.username}/Ventoy";
              };
            }
          ];
        };
      };

      # https://wiki.nixos.org/wiki/Libvirt
      # https://libvirt.org
      libvirtd = mkIf cfg.libvirt.enable {
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
      virtualbox.host = mkIf cfg.virtualbox.enable {
        enable = true;
        enableExtensionPack = true;
      };

      # Allow unprivileged users to redirect USB devices
      spiceUSBRedirection.enable = cfg.libvirt.enable;
    };

    # https://github.com/virt-manager/virt-manager
    programs.virt-manager.enable = cfg.libvirt.enable;

    users.users.${config.custom.username}.extraGroups =
      lib.optionals cfg.libvirt.enable ["libvirtd"]
      ++ lib.optionals cfg.virtualbox.enable ["vboxusers"];

    systemd = mkIf cfg.libvirt.enable {
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
            argument = inputs.nixvirt.lib.guest-install.virtio-win.iso.outPath;
          };
        };

        # TODO: Revisit when merged
        # https://github.com/NixOS/nixpkgs/pull/421549
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

    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
        owner = config.custom.username;
        group = config.users.users.${config.custom.username}.group;
      };
    in {
      "${config.custom.hostname}/vm/myndows.pass" = secret "${config.custom.hostname}/vm/myndows.pass";
    };

    home-manager.sharedModules = [
      {
        home.sessionVariables =
          optionalAttrs cfg.libvirt.enable {
            # https://libvirt.org/uri.html#default-uri-choice
            LIBVIRT_DEFAULT_URI = "qemu:///system";
          }
          // optionalAttrs (with cfg.passthrough; (enable && blacklist)) {
            # https://wiki.archlinux.org/title/PRIME#For_open_source_drivers_-_PRIME
            DRI_PRIME = replaceStrings [":" "."] ["_" "_"] config.custom.settings.hardware.igpu.node;
          };
      }
    ];
  };
}
