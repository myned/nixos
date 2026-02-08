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
          ### CLI applications optionals config.custom.default [
          config.boot.kernelPackages.cpupower # Processor utilities

          bluetui # Bluetooth manager
          btrfs-list # btrfs subvolume lister
          disko # Declarative disk management
          dysk # Filesystem lister
          ethtool # Network device configuration
          fd # File finder
          fzf # Fuzzy search
          host.dnsutils # DNS utils
          hwloc # CPU topology viewer
          inetutils # Network utilities
          inotify-info # File notify lister
          inotify-tools # File notify
          jq # JSON parser
          killall # Kill processes by name
          killport # Kill processes on port
          lazygit # Git client
          lf # Terminal file manager
          lm_sensors # System sensors
          lsof # List open files
          lz4 # Compression utility
          mesa-demos # Graphics tester
          net-snmp # SNMP utils
          nix-output-monitor # Nix build parser
          nix-tree # Nix store explorer
          nmap # Network scanner
          nodejs # npm
          nvd # Nix diff viewer
          openssl # Certificate utility
          pciutils # PCI device information
          perf # Performance analyzer
          progress # Coreutils progress viewer
          q # DNS tester
          rclone # File sync
          sshpass # SSH automation
          stress # CPU stress tester
          tcpdump # Network analyzer
          testdisk # Data recovery tool
          trashy # CLI trash
          uv # Python package manager
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
          deskflow # Software KVM client
          input-leap # Software KVM client
          kdiskmark # Must be system package for polkit
          lan-mouse # Software KVM client

          ### CLI applications
          ffmpeg # Media converter
          firefoxpwa # Web app manager
          libva-utils # VAAPI tools
          mesa-demos # <glx|vk>gears
          vulkan-tools # vkcube
        ]
        ++ optionals config.custom.minimal (with gst_all_1; [
          ### Dependencies
          # https://wiki.nixos.org/wiki/GStreamer
          gst-libav
          gst-plugins-bad
          gst-plugins-base
          gst-plugins-good
          gst-plugins-ugly
          gst-vaapi
          gstreamer
        ])
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
          #// cartridges # Game library

          # BUG: lipsoup deprecated, uncomment when updated to Tauri v2
          # https://github.com/cinnyapp/cinny-desktop/pull/429
          #// cinny-desktop # Matrix client

          #// clapper # Video player
          clickup # Project/task manager
          concessio # Permissions converter
          czkawka # Duplicate file finder
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
          #// fluffychat # Matrix client
          footage # Video editor
          #// fractal # Matrix client
          fragments # Torrent downloader
          gcolor3 # Color picker
          gearlever # AppImage manager
          gimp # Image editor
          #// gitbutler # Git client
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
          gnome-network-displays # Miracast client
          gnome-obfuscate # Image redacter
          gnome-online-accounts-gtk # GNOME accounts
          gnome-podcasts # Podcast feed
          gnome-software # Flatpak manager
          gnome-sound-recorder # Sound recorder
          gnome-system-monitor # System monitor
          gnome-text-editor # Text editor
          gnome-tweaks # GNOME extras
          gnome-usage # System monitor
          gparted # Disk utility
          #// gradience # GTK theme editor
          #// gtk4.dev # GTK4 icon browser
          gtkterm # Serial terminal
          gradia # Screenshot tool
          helvum # Pipewire patchbay
          heroic # Game library
          icon-library # Icon viewer
          identity # Compare media
          impression # Image writer
          inkscape # Vector graphics editor
          itch # Game library
          #// keyguard # Bitwarden client
          kooha # Screen recorder
          #// logseq # Knowledge base
          loupe # Image viewer
          lutris # Game library
          meld # Diff viewer
          mission-center # System monitor
          #// monitorets # System monitor
          newsflash # RSS feed
          #// nicotine-plus # SoulSeek client
          obsidian # Knowledge base
          pantheon.switchboard-with-plugs # System settings
          papers # Document viewer
          #// path-of-building # Path of Exile planner
          picard # Music tagger
          pika-backup # Borg backup manager
          planify # Task manager
          pods # Podman manager
          pkgs.unstable.protonplus # Wine updater
          #// protonvpn-gui # Proton VPN client
          #// ptyxis # Terminal
          pwvucontrol # Pipewire volume controller
          qdiskinfo # Disk information
          remmina # Remote desktop client
          resources # System monitor
          rewaita # Adwaita themer
          rustdesk-flutter # Remote desktop client
          showtime # Video player
          signal-desktop # Signal client
          slack # Slack client
          smile # Emoji picker
          snapshot # Camera
          snoop # File content finder
          sourcegit # Git client
          #// spotify # Spotify client
          #// stremio # Streaming client
          switcheroo # Image converter
          #// syncthingtray # Syncthing client
          tagger # Music tagger
          #// teams-for-linux # Microsoft Teams client
          #// telegram-desktop # Telegram client
          #// variety # Wallpaper changer
          ventoy-full-gtk # Image writer
          virt-viewer # Virtual machine viewer
          #// vorta # Borg backup client
          #// webex # Conferencing client
          wildcard # Regex tester
          #// wowup-cf # World of Warcraft addon manager
          #// xivlauncher # Final Fantasy XIV launcher
          youtube-music # YouTube Music client
          #// zrythm # Digital audio workstation

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

          #// bitwarden-cli # Bitwarden client
          brightnessctl # Backlight changer
          devbox # Development environment
          #// firefoxpwa # Firefox web apps
          freerdp # RDP client
          #// grimblast # Screenshots
          imagemagick # Image editor
          libinput # Libinput commands
          libnotify # Notification tester
          linux-wifi-hotspot # Wi-Fi hotspot
          nixos-anywhere # NixOS installer
          playerctl # Media controller
          #// satty # Screenshot editor
          usbutils # USB bus utilities
          vrrtest # VRR tester
          winetricks # Wine modifier
          xdg-utils # XDG utilities

          ### Dependencies
          wineWowPackages.unstableFull # WoW64, not World of Warcraft

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
