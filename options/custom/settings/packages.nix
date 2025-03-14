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
          alejandra # Nix formatter
          fd # File finder
          fzf # Fuzzy search
          inetutils # Network utilities
          jq # JSON parser
          killport # Kill processes on port
          lf # Terminal file manager
          lm_sensors # System sensors
          lz4 # Compression utility
          nix-output-monitor # Nix build parser
          nix-tree # Nix store explorer
          nmap # Network scanner
          nvd # Nix diff viewer
          openssl # Certificate utility
          progress # Coreutils progress viewer
          q # DNS tester
          rclone # File sync
          sshpass # SSH automation
          stress # CPU stress tester
          testdisk # Data recovery tool
          trashy # CLI trash
          waypipe # Wayland proxy
          wev # Wayland keysym tester
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
          (steamtinkerlaunch.overrideAttrs {src = inputs.steamtinkerlaunch;})

          # Dependencies
          p7zip # steamtinkerlaunch (Special K)
        ]
        ++ optionals config.custom.full [
          ### GUI applications
          alpaca # AI client
          amberol # Audio player
          apostrophe # Markdown editor
          baobab # Disk usage analyzer
          biblioteca # Documentation viewer
          bitwarden-desktop # Password manager
          blackbox-terminal # Terminal
          cartridges # Game library
          cinny-desktop # Matrix client
          clapper # Video player
          concessio # Permissions converter
          d-spy # D-Bus introspection
          dconf-editor # GSettings editor
          decibels # Audio player
          decoder # QR code scanner
          discord # Discord client
          drawio # Diagram maker
          easyeffects # Audio filters
          element-desktop # Matrix client
          file-roller # Archive utility
          flare-signal # Signal client
          fluffychat # Matrix client
          footage # Video editor
          fractal # Matrix client
          fragments # Torrent downloader
          gcolor3 # Color picker
          gitg # Git client
          github-desktop # Git client
          gitnuro # Git client
          gnome-boxes # Virtual machine manager
          gnome-calculator # Calculator
          gnome-calendar # Calendar
          gnome-clocks # Clock
          gnome-connections # Remote desktop client
          gnome-contacts # Contact editor
          gnome-disk-utility # Disk formatter
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
          gnome-system-monitor # System monitor
          gnome-text-editor # Text editor
          gnome-tweaks # GNOME extras
          gnome-usage # System monitor
          gradience # GTK theme editor
          gtk4.dev # GTK4 icon browser
          gtkcord4 # Discord client
          gtkterm # Serial terminal
          helvum # Pipewire patchbay
          heroic # Game library
          icon-library # Icon viewer
          identity # Compare media
          impression # Image writer
          itch # Game library

          # BUG: nixGL required to launch, imperative flatpak used as alternative
          # https://github.com/AChep/keyguard-app/releases
          # https://github.com/gmodena/nix-flatpak/issues/135
          #// keyguard # Bitwarden client

          kooha # Screen recorder

          # BUG: EOL Electron dependency removed from nixpkgs
          # https://github.com/logseq/logseq/issues/11644
          #// logseq # Knowledge base

          loupe # Image viewer
          lutris # Game library
          meld # Diff viewer
          newsflash # RSS feed
          obsidian # Knowledge base
          papers # Document viewer
          path-of-building # Path of Exile planner
          pika-backup # Borg backup manager
          planify # Tasks
          pods # Podman manager
          protonplus # Wine updater
          protonvpn-gui # Proton VPN client
          ptyxis # Terminal
          pwvucontrol # Pipewire volume controller
          remmina # Remote desktop client
          rustdesk-flutter # Remote desktop client
          signal-desktop # Signal client
          smile # Emoji picker
          snapshot # Camera
          snoop # File content finder
          sourcegit # Git client
          spotify # Spotify client
          syncthingtray # Syncthing client
          tagger # Audio file tagger
          telegram-desktop # Telegram client
          variety # Wallpaper changer
          ventoy # Image writer
          virt-viewer # Virtual machine viewer
          wildcard # Regex tester
          wowup-cf # World of Warcraft addon manager
          #// xivlauncher # Final Fantasy XIV launcher
          youtube-music # YouTube Music client
          zrythm # Digital audio workstation

          #!! Must be downloaded manually due to licensing
          # BUG: Dangling symlinks, remove workaround when merged into unstable
          # https://github.com/NixOS/nixpkgs/pull/380309
          ((ciscoPacketTracer8.overrideAttrs {
              dontCheckForBrokenSymlinks = true;
            })
            .override {
              packetTracerSource = inputs.cisco-packettracer8;
            })

          ### CLI applications
          inputs.agenix.packages.${system}.default

          betterdiscordctl # BetterDiscord installer
          bitwarden-cli # Bitwarden client
          brightnessctl # Backlight changer
          devbox # Development environment
          er-patcher # Elden Ring fixes
          firefoxpwa # Firefox web apps
          glxinfo # Graphics tester
          hwloc # CPU topology viewer
          freerdp3 # RDP client
          grimblast # Screenshots
          imagemagick # Image editor
          libinput # Libinput commands
          libnotify # Notification tester
          linux-wifi-hotspot # Wi-Fi hotspot
          nixos-anywhere # NixOS installer
          nvtopPackages.full # GPU monitor
          playerctl # Media controller
          satty # Screenshot editor
          tio # Serial terminal
          usbutils # USB bus utilities
          vrrtest # VRR tester
          winetricks # Wine modifier
          xdg-utils # XDG utilities
          ydotool # TODO: Remove when using service

          ### Dependencies
          wineWowPackages.unstableFull # WoW64, not World of Warcraft

          # TODO: Use home.gtk.theme.package when fixed upstream
          # https://github.com/nix-community/home-manager/issues/5133
          adw-gtk3

          ### Python packages
          # TODO: Separate into standalone package for absolute path reference
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
