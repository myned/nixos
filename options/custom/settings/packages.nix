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
        ++ optionals config.custom.default (with config.boot.kernelPackages; [
          ### CLI applications
          cpupower # Processor utilities
          perf # Performance analyzer
        ])
        ++ optionals config.custom.default [
          btrfs-list # btrfs subvolume lister
          disko # Declarative disk management
          ethtool # Network device configuration
          fd # File finder
          fzf # Fuzzy search
          glances # System monitor
          glxinfo # Graphics tester
          hwloc # CPU topology viewer
          inetutils # Network utilities
          jq # JSON parser
          killport # Kill processes on port
          lf # Terminal file manager
          lm_sensors # System sensors
          lsof # List open files
          lz4 # Compression utility
          nix-output-monitor # Nix build parser
          nix-tree # Nix store explorer
          nmap # Network scanner
          nodejs # npm
          nvd # Nix diff viewer
          openssl # Certificate utility
          pciutils # PCI device information
          progress # Coreutils progress viewer
          q # DNS tester
          rclone # File sync
          sshpass # SSH automation
          stress # CPU stress tester
          tcpdump # Network analyzer
          testdisk # Data recovery tool
          trashy # CLI trash
          waypipe # Wayland proxy
          wev # Wayland keysym tester
          wget # Download utility
          wl-clipboard # Wayland clipboard
          xclip # X11 clipboard
          xorg.xev # X11 keysym tester
          zip # Compression utility

          ### Dependencies
          man-pages
          man-pages-posix
        ]
        ++ optionals config.custom.minimal [
          ### GUI applications
          kdiskmark # Must be system package for polkit

          ### CLI applications
          mesa-demos # <glx|vk>gears
          vulkan-tools # vkcube

          # https://github.com/sonic2kk/steamtinkerlaunch
          # TODO: Remove when v14 released on nixpkgs
          # https://github.com/sonic2kk/steamtinkerlaunch/issues/992
          # Build from latest commit
          #// (steamtinkerlaunch.overrideAttrs {src = inputs.steamtinkerlaunch;})

          # Dependencies
          #// p7zip # steamtinkerlaunch (Special K)
        ]
        ++ optionals config.custom.full [
          ### GUI applications
          #// alpaca # Ollama client
          amberol # Audio player
          apostrophe # Markdown editor
          baobab # Disk usage analyzer
          biblioteca # Documentation viewer
          bitwarden-desktop # Password manager
          #// blackbox-terminal # Terminal
          blueberry # Bluetooth manager
          bottles # Wine manager
          cartridges # Game library
          cinny-desktop # Matrix client
          #// clapper # Video player
          concessio # Permissions converter
          d-spy # D-Bus introspection
          dconf-editor # GSettings editor
          decibels # Audio player
          decoder # QR code scanner
          drawing # Image editor
          drawio # Diagram maker
          eartag # Music tagger
          easyeffects # Audio filters
          element-desktop # Matrix client
          eyedropper # Color picker
          feishin # Jellyfin client
          file-roller # Archive utility
          #// flare-signal # Signal client
          fluffychat # Matrix client
          footage # Video editor
          #// fractal # Matrix client
          fragments # Torrent downloader
          gcolor3 # Color picker
          gimp # Image editor
          gitbutler # Git client
          #// gitg # Git client
          github-desktop # Git client
          gitnuro # Git client
          gnome-boxes # Virtual machine manager
          gnome-calculator # Calculator
          gnome-calendar # Calendar
          gnome-clocks # Clock
          gnome-connections # Remote desktop client
          gnome-contacts # Contact editor
          gnome-disk-utility # Disk utility
          gnome-feeds # RSS feed client
          gnome-firmware # Firmware updater
          gnome-font-viewer # Font viewer
          gnome-frog # Text extraction
          gnome-graphs # Data plotter
          gnome-maps # OpenStreetMap client
          gnome-obfuscate # Image redacter
          gnome-online-accounts-gtk # GNOME accounts
          gnome-podcasts # Podcast feed
          gnome-resources # System monitor
          gnome-software # Flatpak manager
          gnome-sound-recorder # Sound recorder
          gnome-system-monitor # System monitor
          gnome-text-editor # Text editor
          gnome-tweaks # GNOME extras
          gnome-usage # System monitor
          gparted # Disk utility
          #// gradience # GTK theme editor
          gtk4.dev # GTK4 icon browser
          gtkterm # Serial terminal
          helvum # Pipewire patchbay
          heroic # Game library
          icon-library # Icon viewer
          identity # Compare media
          impression # Image writer
          inkscape # Vector graphics editor
          itch # Game library
          keyguard # Bitwarden client
          kooha # Screen recorder
          #// logseq # Knowledge base
          loupe # Image viewer
          lutris # Game library
          meld # Diff viewer
          mission-center # System monitor
          #// monitorets # System monitor
          newsflash # RSS feed
          nicotine-plus # SoulSeek client
          obsidian # Knowledge base
          papers # Document viewer
          path-of-building # Path of Exile planner
          picard # Music tagger
          pika-backup # Borg backup manager

          # BUG: gxml build failure, uncomment when fixed
          # https://github.com/NixOS/nixpkgs/issues/407969
          #// planify # Task list

          pods # Podman manager
          protonplus # Wine updater
          #// protonvpn-gui # Proton VPN client
          #// ptyxis # Terminal
          pwvucontrol # Pipewire volume controller
          qdiskinfo # Disk information
          remmina # Remote desktop client
          rustdesk-flutter # Remote desktop client
          showtime # Video player
          signal-desktop-bin # Signal client
          smile # Emoji picker
          snapshot # Camera
          snoop # File content finder
          sourcegit # Git client
          #// spotify # Spotify client
          stremio # Streaming client
          #// syncthingtray # Syncthing client
          tagger # Music tagger
          #// telegram-desktop # Telegram client
          #// variety # Wallpaper changer
          ventoy # Image writer
          virt-viewer # Virtual machine viewer
          vorta # Borg backup client
          wildcard # Regex tester
          #// wowup-cf # World of Warcraft addon manager
          #// xivlauncher # Final Fantasy XIV launcher
          youtube-music # YouTube Music client
          zrythm # Digital audio workstation

          #!! Must be downloaded manually due to licensing
          # BUG: Dangling symlinks, remove workaround when merged into unstable
          # https://github.com/NixOS/nixpkgs/pull/380309
          # ((ciscoPacketTracer8.overrideAttrs {
          #     dontCheckForBrokenSymlinks = true;
          #   })
          #   .override {
          #     packetTracerSource = inputs.cisco-packettracer8;
          #   })

          ### CLI applications
          inputs.agenix.packages.${system}.default

          bitwarden-cli # Bitwarden client
          brightnessctl # Backlight changer
          devbox # Development environment
          er-patcher # Elden Ring fixes
          #// firefoxpwa # Firefox web apps
          freerdp3 # RDP client
          #// grimblast # Screenshots
          imagemagick # Image editor
          libinput # Libinput commands
          libnotify # Notification tester
          linux-wifi-hotspot # Wi-Fi hotspot
          nixos-anywhere # NixOS installer
          nvtopPackages.full # GPU monitor
          playerctl # Media controller
          #// satty # Screenshot editor
          usbutils # USB bus utilities
          vrrtest # VRR tester
          winetricks # Wine modifier
          xdg-utils # XDG utilities

          ### Dependencies
          wineWowPackages.unstableFull # WoW64, not World of Warcraft

          # TODO: Use home.gtk.theme.package when fixed upstream
          # https://github.com/nix-community/home-manager/issues/5133
          adw-gtk3

          ### Python packages
          # TODO: Separate into standalone package for absolute path reference
          # https://wiki.nixos.org/wiki/Python#Package_unavailable_in_Nixpkgs
          # https://wiki.nixos.org/wiki/Packaging/Python
          (python312.withPackages (
            ps:
              with ps; [
                # lifx-cli
                # https://github.com/Rawa/lifx-cli
                (buildPythonPackage {
                  pname = "lifx-cli";
                  version = "master";
                  src = inputs.lifx-cli;
                  doCheck = false;
                  pyproject = true;
                  build-system = with ps; [setuptools];
                  propagatedBuildInputs = [requests];
                })
              ]
          ))
        ];
    }
  );
}
