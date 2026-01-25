{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.sunshine;
in {
  options.custom.services.sunshine = {
    enable = mkEnableOption "sunshine";
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Sunshine
    # https://docs.lizardbyte.dev/projects/sunshine/latest/
    # https://github.com/LizardByte/Sunshine
    #?? https://localhost:47990
    services.sunshine = {
      enable = true;
      openFirewall = true; # 47984/tcp 47989/tcp 47990/tcp 48010/tcp 47998-48000/udp
      capSysAdmin = true;

      # https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html
      settings = {
        adapter_name = "/dev/dri/by-path/${config.custom.settings.hardware.igpu.node}-render"; #!! Must match output renderer
        address_family = "both"; # IPv4+IPv6
        capture = "kms"; # nvfbc|wlr|kms|x11|ddx|wgc
        encoder = "vaapi"; # nvenc|quicksync|amdvce|vaapi|software
        system_tray = "disabled";
        #// vaapi_strict_rc_buffer = "enabled"; # Less dropped frames
        wan_encryption_mode = 2; # Require encryption
      };

      # https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2app__examples.html
      applications = {
        # https://github.com/LizardByte/Sunshine/tree/master/src_assets
        # https://github.com/LizardByte/Sunshine/blob/master/src_assets/linux/assets/apps.json
        # https://github.com/LizardByte/Sunshine/blob/master/src_assets/common/assets/web/public/assets/locale/en.json
        apps = [
          {
            name = "Desktop";
            image-path = "desktop.png";
          }

          {
            name = "Desktop 16x9";
            image-path = "desktop-alt.png";
            prep-cmd = [
              {
                do = "kanshictl switch 16x9";
                undo = "kanshictl switch default";
              }
            ];
          }

          {
            name = "Steam Gamescope";
            image-path = "steam.png";
            prep-cmd = with config.custom.programs.steam.gamescope; [
              {
                do = ''sh -c "sudo openvt -sfc ${toString console} -- agetty -ca $USER - linux"'';
                undo = ''sh -c "steam -shutdown && sudo pkill -9 -t tty${toString console} && sudo chvt 1"'';
              }
            ];
          }
        ];
      };
    };
  };
}
