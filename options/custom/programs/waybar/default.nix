{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  audio = config.home-manager.users.${config.custom.username}.home.file.".local/bin/audio".source;
  bash = "${pkgs.bash}/bin/bash";
  blueberry = "${pkgs.blueberry}/bin/blueberry";
  bluetoothctl = "${pkgs.bluez}/bin/bluetoothctl";
  cat = "${pkgs.coreutils}/bin/cat";
  easyeffects = "${pkgs.easyeffects}/bin/easyeffects";
  echo = "${pkgs.coreutils}/bin/echo";
  grep = "${pkgs.gnugrep}/bin/grep";
  hyprctl = "${config.programs.hyprland.package}/bin/hyprctl";
  inhibit = config.home-manager.users.${config.custom.username}.home.file.".local/bin/inhibit".source;
  jq = "${pkgs.jq}/bin/jq";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  network = config.home-manager.users.${config.custom.username}.home.file.".local/bin/network".source;
  nm-connection-editor = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
  pgrep = "${pkgs.procps}/bin/pgrep";
  ping = "${pkgs.iputils}/bin/ping";
  pkill = "${pkgs.procps}/bin/pkill";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  power = config.home-manager.users.${config.custom.username}.home.file.".local/bin/power".source;
  rfkill = "${pkgs.util-linux}/bin/rfkill";
  sleep = "${pkgs.coreutils}/bin/sleep";
  swaync-client = "${config.home-manager.users.${config.custom.username}.services.swaync.package}/bin/swaync-client";
  swayosd-client = "${pkgs.swayosd}/bin/swayosd-client";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  systemd-inhibit = "${pkgs.systemd}/bin/systemd-inhibit";
  tailscale = "${pkgs.tailscale}/bin/tailscale";
  tr = "${pkgs.coreutils}/bin/tr";
  vm = config.home-manager.users.${config.custom.username}.home.file.".local/bin/vm".source;
  vpn = config.home-manager.users.${config.custom.username}.home.file.".local/bin/vpn".source;
  wttrbar = "${pkgs.wttrbar}/bin/wttrbar";

  cfg = config.custom.programs.waybar;
in {
  options.custom.programs.waybar.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/Alexays/Waybar
    # https://www.nerdfonts.com/cheat-sheet
    programs.waybar = {
      enable = true;
      systemd.enable = true; # Start on login

      # ?? waybar --log-level debug
      style = ''
        ${readFile ./style.css}

        .horizontal > box {
          margin: 0 ${toString config.custom.gap}px ${toString config.custom.gap}px;
        }
      '';

      ### SETTINGS ###
      # https://github.com/Alexays/Waybar/wiki/Configuration
      #?? pkill -SIGUSR2 -x waybar
      settings = let
        ## INHERIT ##
        #!! Module defaults are not accurate to documentation
        # TODO: Submit pull request to fix in addition to inconsistent hyphen vs underscore
        # https://github.com/Alexays/Waybar/wiki/Module:-Cava
        cava-config = {
          cava_config = null; # Default: null?
          framerate = 30; # Default: 30?
          autosens = 1; # Default: 1
          # sensitivity = 0; # Default: 100?
          bars = 16; # Default: 2
          lower_cutoff_freq = 50; # Default: 50?
          higher_cutoff_freq = 10000; # Default: 10000?
          sleep_timer = 5; # Default: 0
          hide_on_silence = true; # Default: false
          method = "pipewire"; # Default: pulse
          source = "auto"; # Default: auto?
          sample_rate = 44100; # Default: 44100?
          sample_bits = 16; # Default: 16?
          stereo = false; # Default: true
          reverse = false; # Default: false
          bar_delimiter = 32; # ASCII code for space, default: 59 or ;
          monstercat = true; # Default: false?
          waves = true; # Default: false?
          noise_reduction = 0.2; # Default: 0.77?
          input_delay = 1; # Default: 4
          format-icons = [
            "▁"
            "▂"
            "▃"
            "▄"
            "▅"
            "▆"
            "▇"
            "█"
          ]; # !! Required
          on-click = easyeffects;
          on-scroll-up = "${swayosd-client} --output-volume raise";
          on-scroll-down = "${swayosd-client} --output-volume lower";
          rotate = 180;
        };
      in {
        status = {
          reload_style_on_change = true; # Reload CSS when modified

          ## GLOBAL ##
          layer = "top";
          position = "bottom";

          ## POSITION ##
          modules-left = [
            "custom/power"
            "custom/inhibitor"
            "custom/vpn"
            "custom/vm"
            "hyprland/workspaces"
          ];
          modules-center = [
            "clock"
            "custom/weather"
          ];
          modules-right = [
            "mpris"
            "tray"
            "custom/equalizer"
            "wireplumber"
            "bluetooth"
            "network"
            "battery"
          ];

          ## MODULES ##
          # https://github.com/Alexays/Waybar/wiki/Module:-Custom
          "custom/power" = {
            format = "";
            on-click = "${systemctl} poweroff";
            on-click-right = "${systemctl} reboot";
            on-click-middle = "${loginctl} terminate-session ''";
          };

          "custom/inhibitor" = {
            interval = 5;
            exec = "~/.config/waybar/scripts/inhibitor.sh";
            on-click = inhibit;
          };

          "custom/vm" = {
            interval = 5;
            exec = "~/.config/waybar/scripts/vm.sh";
            on-click = "${vm} -x ${
              if config.custom.hidpi
              then "/scale:140"
              else ""
            }";
          };

          "custom/vpn" = {
            interval = 5;
            exec = "~/.config/waybar/scripts/vpn.sh";
            on-click = "${vpn} mypi3";
          };

          # https://github.com/Alexays/Waybar/wiki/Module:-Idle-Inhibitor
          # FIXME: Not currently usable
          # https://github.com/Alexays/Waybar/issues/690
          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "󰅶";
              deactivated = "󰾪";
            };
          };

          # https://github.com/Alexays/Waybar/wiki/Module:-Hyprland
          # https://www.nerdfonts.com/cheat-sheet
          "hyprland/workspaces" = {
            show-special = true;
            format = "{icon}";
            format-icons = {
              android = "";
              dropdown = "󰞷";
              game = "󰊴";
              music = "󰝚";
              office = "󰈙";
              password = "󰌾";
              pip = "󰹙";
              scratchpad = "";
              steam = "󰓓";
              terminal = "";
              vm = "󰢹";
              wallpaper = "󰏩";
            };
          };

          cava = cava-config;

          # https://github.com/Alexays/Waybar/wiki/Module:-Clock
          clock = {
            # https://fmt.dev/latest/syntax.html#chrono-specs
            format = "{:%a %b %d   %I:%M %p}"; # Mon Jan 01  12:00 AM
            tooltip-format = "{calendar}";
            calendar.format = {
              months = "<span color='#eee8d5'>{}</span>";
              weeks = "<span color='#eee8d5'>{}</span>";
              weekdays = "<span color='#93a1a1'>{}</span>";
              days = "<span color='#586e75'>{}</span>";
              today = "<span color='#eee8d5'>{}</span>";
            };

            # FIXME: Click release event sends to incorrect layer without sleeping
            # https://github.com/hyprwm/Hyprland/issues/1348
            on-click = "${swaync-client} --toggle-panel";
            # on-click-right = easyeffects;
            on-scroll-up = "${swayosd-client} --output-volume raise";
            on-scroll-down = "${swayosd-client} --output-volume lower";
          };

          # https://github.com/bjesus/wttrbar
          "custom/weather" = {
            format = "{}°";
            interval = 60 * 60;
            return-type = "json";

            exec = lib.strings.concatStringsSep " " [
              "${wttrbar}"
              "--ampm"
              "--fahrenheit"
              "--hide-conditions"
              "--main-indicator temp_F"
            ];
          };

          "cava#reverse" =
            cava-config
            // {
              reverse = true;
            };

          "custom/equalizer" = {
            interval = 5;
            on-click = audio;
            exec = pkgs.writeShellScript "equalizer.sh" ''
              ${echo} 󰺢
              ${echo} "$(${cat} ~/.audio)"
              ${echo} "$(${cat} ~/.audio | ${tr} '[:upper:]' '[:lower:]')"
            '';
          };

          # https://github.com/Alexays/Waybar/wiki/Module:-MPRIS
          mpris = {
            format = "{player_icon} {dynamic}";
            format-paused = "{status_icon} {dynamic}";
            dynamic-len = 50;
            dynamic-order = [
              "title"
              "artist"
            ];
            dynamic-separator = " 󰧟 ";
            player-icons.default = "󰎈";
            status-icons.paused = "";
            on-click-middle = ""; # TODO: Close music player
            on-scroll-up = "${swayosd-client} --output-volume raise";
            on-scroll-down = "${swayosd-client} --output-volume lower";
          };

          # https://github.com/Alexays/Waybar/wiki/Module:-WirePlumber
          wireplumber = {
            format = "{icon} {volume}%";
            format-muted = "󰸈";
            format-icons = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
            on-click = easyeffects;
            on-click-right = "${swayosd-client} --output-volume mute-toggle";
            on-scroll-up = "${swayosd-client} --output-volume raise";
            on-scroll-down = "${swayosd-client} --output-volume lower";
          };

          # https://github.com/Alexays/Waybar/wiki/Module:-Bluetooth
          bluetooth = {
            format-disabled = "󰂲";
            format-off = "󰂲";
            format-on = "󰂯";
            format-connected = "󰂱";
            on-click = blueberry;
            on-click-right = "${bluetoothctl} disconnect";
            on-click-middle = "${rfkill} toggle bluetooth"; # Toggle bluetooth on/off
          };

          # https://github.com/Alexays/Waybar/wiki/Module:-Network
          network = {
            format = "{icon}";
            format-icons = {
              disabled = "";
              disconnected = "";
              ethernet = "󰈀";
              linked = "";
              wifi = [
                "󰤯"
                "󰤟"
                "󰤢"
                "󰤥"
                "󰤨"
              ];
            };

            on-click = nm-connection-editor;
            on-click-right = network; # Toggle networking on/off
          };

          # https://github.com/Alexays/Waybar/wiki/Module:-Battery
          "battery" = {
            format = "{icon} {power:.0f}W";
            format-icons = [
              "󰂃"
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
            interval = 5;
            states = {
              critical = 15;
              warning = 30;
            };

            on-click = power; # Toggle power-saver mode
          };
        };
      };
    };

    # TODO: Convert to writeShellApplication
    ### SCRIPTS ###
    #?? text
    #?? tooltip
    #?? class
    home.file = {
      # Return inhibit idle status
      ".config/waybar/scripts/inhibitor.sh" = {
        executable = true;
        text = ''
          #! /usr/bin/env ${bash}

          if ${pgrep} systemd-inhibit &> /dev/null; then
            ${echo} 󰅶
            ${echo} Enabled
            ${echo} enabled
          else
            ${echo} 󰾪
            ${echo} Disabled
            ${echo} disabled
          fi
        '';
      };

      # Return tailscale status
      ".config/waybar/scripts/vm.sh" = {
        executable = true;
        text = ''
          #! /usr/bin/env ${bash}

          case "$(virsh domstate myndows)" in
            'running')
              ${echo} 
              ${echo} Online
              ${echo} online;;
            'paused')
              ${echo} 
              ${echo} Paused
              ${echo} paused;;
            'shut off')
              ${echo} 
              ${echo} Offline
              ${echo} offline;;
            *)
              ${echo} 
              ${echo} Unknown
              ${echo} unknown;;
          esac
        '';
      };

      # Return tailscale status
      ".config/waybar/scripts/vpn.sh" = {
        executable = true;
        text = ''
          #! /usr/bin/env ${bash}

          if [[ $(${tailscale} status --json | ${jq} .ExitNodeStatus.Online) == 'true' ]]; then
            ${echo} 󰖂
            ${echo} Connected
            ${echo} connected
          else
            ${echo} 󰖂
            ${echo} Disconnected
            ${echo} disconnected
          fi
        '';
      };
    };
  };
}
