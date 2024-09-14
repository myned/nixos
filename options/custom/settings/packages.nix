{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.packages;
in {
  options.custom.settings.packages = {
    enable = mkOption {default = false;};
    extra = mkOption {default = [];};
  };

  config = mkIf cfg.enable (
    with pkgs; {
      environment.systemPackages =
        cfg.extra
        ++ [
          # CLI applications
          config.boot.kernelPackages.cpupower # Install for current kernel

          alejandra
          fd
          fzf
          jq
          lm_sensors # sensors
          nix-output-monitor # nom
          nix-tree
          nmap
          nvd
          progress
          rclone
          stress
          trashy
          waypipe
          wl-clipboard # wl-copy/wl-paste
          xclip

          # Dependencies
          man-pages
          man-pages-posix
        ]
        ++ optionals config.custom.minimal [
          # GUI applications
          kdiskmark # Must be system package for polkit

          # CLI applications
          # https://github.com/sonic2kk/steamtinkerlaunch
          # TODO: Remove when v14 released on nixpkgs
          # https://github.com/sonic2kk/steamtinkerlaunch/issues/992
          # Build from latest commit
          (steamtinkerlaunch.overrideAttrs {src = inputs.steamtinkerlaunch;})

          # Dependencies
          p7zip # steamtinkerlaunch (Special K)
        ]
        ++ optionals config.custom.full [
          # GUI applications
          amberol
          baobab
          bitwarden
          blackbox-terminal
          cinny-desktop
          d-spy
          dconf-editor
          discord
          easyeffects
          element-desktop
          evince
          flare-signal
          fluffychat
          #// fractal
          gcolor3
          gitg
          github-desktop
          gnome-boxes
          gnome-calculator
          gnome-calendar
          gnome-connections
          gnome-console
          gnome-disk-utility
          gnome-resources
          gnome-software
          gnome-system-monitor
          gnome-text-editor
          gnome-tweaks
          gnome-usage
          gradience
          gtkcord4
          gtkterm
          heroic
          icon-library
          impression
          logseq
          loupe
          lutris
          nheko
          obsidian
          onlyoffice-bin
          path-of-building
          pika-backup
          protonup-qt
          protonvpn-gui
          pwvucontrol
          remmina
          snapshot
          spotify
          syncthingtray
          telegram-desktop
          variety
          ventoy
          virt-viewer
          wildcard
          wowup-cf
          #// xivlauncher
          youtube-music

          #!! Must be downloaded manually due to licensing
          (ciscoPacketTracer8.overrideAttrs {
            src = /home/myned/SYNC/linux/config/cisco/CiscoPacketTracer822_amd64_signed.deb;
          })

          # CLI applications
          inputs.agenix.packages.${system}.default

          betterdiscordctl
          bitwarden-cli
          brightnessctl
          devbox
          er-patcher # Elden Ring fixes
          firefoxpwa
          glxinfo # glxgears
          hwloc # lstopo
          freerdp3
          grimblast
          imagemagick
          libinput
          libnotify # notify-send
          linux-wifi-hotspot # create_ap
          nixos-anywhere
          nvtopPackages.full # nvtop
          playerctl
          satty
          tio
          usbutils # lsusb
          vrrtest
          winetricks
          xdg-utils # xdg-open
          ydotool # TODO: Remove when using service

          # Dependencies
          wineWowPackages.unstableFull # WoW64, not World of Warcraft

          # TODO: Use home.gtk.theme.package when fixed upstream
          # https://github.com/nix-community/home-manager/issues/5133
          adw-gtk3

          # Python packages
          # https://wiki.nixos.org/wiki/Python#Package_unavailable_in_Nixpkgs
          # https://wiki.nixos.org/wiki/Packaging/Python
          (python311.withPackages (
            ps:
              with ps; [
                # lifx-cli
                # https://github.com/Rawa/lifx-cli
                (buildPythonPackage {
                  pname = "lifx-cli";
                  version = "master";
                  src = inputs.lifx-cli;
                  doCheck = false;
                  propagatedBuildInputs = with python311Packages; [requests];
                })
              ]
          ))
        ];
    }
  );
}
