{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.vms.myndows;
in {
  options.custom.vms.myndows = {
    enable = mkEnableOption "myndows";
  };

  config = mkIf cfg.enable {
    #!! Allocates available storage
    # https://github.com/AshleyYakeley/NixVirt?tab=readme-ov-file#libvolumegetxml
    custom.vms.libvirt.images = [
      {
        definition = with inputs.nixvirt.lib.volume;
          writeXML {
            name = "myndows.qcow2";
            target.format.type = "qcow2";

            capacity = {
              count = 64;
              unit = "GiB";
            };
          };
      }
    ];

    # https://github.com/AshleyYakeley/NixVirt?tab=readme-ov-file#libdomaingetxml
    virtualisation.libvirt.connections."qemu:///system".domains = with inputs.nixvirt.lib.domain; [
      {
        # https://github.com/AshleyYakeley/NixVirt?tab=readme-ov-file#libdomaintemplateswindows
        # https://github.com/AshleyYakeley/NixVirt/blob/master/templates/domain/windows.nix
        # https://github.com/AshleyYakeley/NixVirt/blob/master/checks/domain/win11/input.nix
        definition = writeXML (recursiveUpdate (templates.windows {
            ### Template
            name = "myndows";
            uuid = "65bbdc6e-59b5-4a15-8791-dff46b94842d";
            install_vol = "/run/media/${config.custom.username}/Ventoy/Win11_24H2_English_x64.iso";
            nvram_path = "/var/lib/libvirt/qemu/nvram/myndows_VARS.fd";
            bridge_name = "virbr0";
            virtio_drive = true;
            virtio_net = true;
            virtio_video = true;
            install_virtio = true;
            vcpu.count = 8;

            memory = {
              count = 8;
              unit = "GiB";
            };

            storage_vol = {
              pool = "default";
              volume = "myndows.qcow2";
            };
          }) {
            ### Overrides
            cpu.topology = {
              sockets = 1;
              dies = 1;
              clusters = 1;
              cores = 4;
              threads = 2;
            };
          });
      }
    ];
  };
}
