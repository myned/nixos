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
        ++ optionals config.custom.default [
          ### CLI applications
          config.boot.kernelPackages.cpupower # Install for current kernel

          alejandra # Nix formatter
          fd # File finder
          fzf # Fuzzy search
          jq # JSON parser
          killport # Kill processes on port
          libqalculate # Calculator
          lm_sensors # System sensors
          nix-output-monitor # Nix build parser
          nix-tree # Nix store explorer
          nmap # Network scanner
          nvd # Nix diff viewer
          progress # Coreutils progress viewer
          rclone # File sync
          stress # CPU stress tester
          trashy # CLI trash
          waypipe # Wayland proxy
          wl-clipboard # Wayland clipboard
          xclip # X11 clipboard

          ### Dependencies
          man-pages
          man-pages-posix
        ]
        ++ optionals config.custom.minimal [
          ### GUI applications
          kdiskmark # Must be system package for polkit

          ### CLI applications
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
          amberol # Audio player
          apostrophe # Markdown editor
          baobab # Disk usage analyzer
          blackbox-terminal # Terminal
          cartridges # Game library
          cinny-desktop # Matrix client
          d-spy # D-Bus introspection
          dconf-editor # GSettings editor
          decibels # Audio player
          decoder # QR code scanner
          discord # Discord client
          drawio # Diagram maker
          easyeffects # Audio filters
          element-desktop # Matrix client
          flare-signal # Signal client
          fluffychat # Matrix client
          footage # Video editor
          #// fractal # Matrix client
          fragments # Torrent downloader
          gcolor3 # Color picker
          gitg # Git client
          github-desktop # Git client
          gnome-boxes # Virtual machine manager
          gnome-calculator # Calculator
          gnome-calendar # Calendar
          gnome-connections # Remote desktop client
          gnome-disk-utility # Disk formatter
          gnome-font-viewer # Font viewer
          gnome-graphs # Data plotter
          gnome-maps # OpenStreetMap client
          gnome-obfuscate # Image redacter
          gnome-podcasts # Podcast feed
          gnome-resources # System monitor
          gnome-software # Flatpak manager
          gnome-system-monitor # System monitor
          gnome-text-editor # Text editor
          gnome-tweaks # GNOME extras
          gnome-usage # System monitor
          gradience # GTK theme editor
          gtkcord4 # Discord client
          gtkterm # Serial terminal
          helvum # Pipewire patchbay
          heroic # Game library
          icon-library # Icon viewer
          identity # Compare media
          impression # Image writer
          kooha # Screen recorder
          logseq # Knowledge base
          loupe # Image viewer
          lutris # Game library
          newsflash # RSS feed
          nheko # Matrix client
          obsidian # Knowledge base
          onlyoffice-bin # Document editor
          papers # Document viewer
          path-of-building # Path of Exile planner
          pika-backup # Borg backup manager
          planify # Tasks
          pods # Podman manager
          protonup-qt # Proton updater
          protonvpn-gui # Proton VPN client
          pwvucontrol # Pipewire volume controller
          remmina # Remote desktop client
          signal-desktop # Signal client
          smile # Emoji picker
          snapshot # Camera
          snoop # File content finder
          spotify # Spotify client
          syncthingtray # Syncthing client
          tagger # Audio file tagger
          telegram-desktop # Telegram client
          turtle # Git client
          variety # Wallpaper changer
          ventoy # Image writer
          virt-viewer # Virtual machine viewer
          wildcard # Regex tester
          wowup-cf # World of Warcraft addon manager
          #// xivlauncher # Final Fantasy XIV launcher
          youtube-music # YouTube Music client
          zrythm # Digital audio workstation

          #!! Must be downloaded manually due to licensing
          # (ciscoPacketTracer8.overrideAttrs {
          #   src = /home/myned/SYNC/linux/config/cisco/CiscoPacketTracer822_amd64_signed.deb;
          # })

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
