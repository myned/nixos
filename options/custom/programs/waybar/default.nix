{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  audio = config.home-manager.users.${config.custom.username}.home.file.".local/bin/audio".source;
  blueberry = "${pkgs.blueberry}/bin/blueberry";
  bluetoothctl = "${pkgs.bluez}/bin/bluetoothctl";
  cat = "${pkgs.coreutils}/bin/cat";
  date = "${pkgs.coreutils}/bin/date";
  easyeffects = "${pkgs.easyeffects}/bin/easyeffects";
  echo = "${pkgs.coreutils}/bin/echo";
  gnome-calendar = "${pkgs.gnome-calendar}/bin/gnome-calendar";
  gnome-clocks = "${pkgs.gnome-clocks}/bin/gnome-clocks";
  gnome-weather = "${pkgs.gnome-weather}/bin/gnome-weather";
  inhibit = config.home-manager.users.${config.custom.username}.home.file.".local/bin/inhibit".source;
  jq = "${pkgs.jq}/bin/jq";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  network = config.home-manager.users.${config.custom.username}.home.file.".local/bin/network".source;
  niri = "${config.programs.niri.package}/bin/niri";
  nm-connection-editor = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
  pgrep = "${pkgs.procps}/bin/pgrep";
  pwvucontrol = "${pkgs.pwvucontrol}/bin/pwvucontrol";
  remote = config.home-manager.users.${config.custom.username}.home.file.".local/bin/remote".source;
  rfkill = "${pkgs.util-linux}/bin/rfkill";
  swaync-client = "${config.home-manager.users.${config.custom.username}.services.swaync.package}/bin/swaync-client";
  swayosd-client = "${pkgs.swayosd}/bin/swayosd-client";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  tailscale = "${pkgs.tailscale}/bin/tailscale";
  tr = "${pkgs.coreutils}/bin/tr";
  virsh = "${pkgs.libvirt}/bin/virsh";
  virt-manager = "${pkgs.virt-manager}/bin/virt-manager";
  vpn = config.home-manager.users.${config.custom.username}.home.file.".local/bin/vpn".source;
  wttrbar = "${pkgs.wttrbar}/bin/wttrbar";

  cfg = config.custom.programs.waybar;
in {
  options.custom.programs.waybar = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
        owner = config.custom.username;
        group = "users";
      };
    in {
      "desktop/vm/myndows.pass" = secret "desktop/vm/myndows.pass";
    };

    home-manager.sharedModules = [
      {
        # https://github.com/Alexays/Waybar
        #!! Some settings need a restart to take effect
        #?? systemctl --user restart waybar
        #?? pkill -SIGUSR2 -x waybar
        programs.waybar = {
          enable = true;
          systemd.enable = true;

          # https://github.com/Alexays/Waybar/wiki/Styling
          #?? GTK_DEBUG=interactive waybar
          style = let
            border = toString config.custom.border;
            font = config.custom.settings.fonts.monospace;
            gap = toString config.custom.gap;
          in ''
            * {
              border-radius: 50px;
              color: #93a1a1;
              font: 18px '${font}';
              margin: 0;
              padding: 0;
              text-shadow: none;
            }

            .horizontal > box {
              border: ${border} solid #073642;
              margin: 0 ${gap}px ${gap}px;
            }

            ${readFile ./style.css}
          '';

          # https://github.com/Alexays/Waybar/wiki/Configuration
          # https://docs.gtk.org/Pango/pango_markup.html#pango-markup
          # https://www.nerdfonts.com/cheat-sheet
          settings = let
            # Common module settings
            #!! Some settings are commonly available for use but not documented per module
            common = {
              # https://github.com/Alexays/Waybar/issues/1800
              smooth-scrolling-threshold = 1; #!! Affects discrete scroll events

              on-scroll-down =
                if config.custom.desktop == "niri"
                then "${niri} msg action focus-workspace-down"
                else "";

              on-scroll-up =
                if config.custom.desktop == "niri"
                then "${niri} msg action focus-workspace-up"
                else "";
            };

            #!! Module defaults are not accurate to documentation
            cava =
              common
              // {
                autosens = 1; # Default: 1
                bar_delimiter = 32; # ASCII code for space, default: 59 or ;
                bars = 16; # Default: 2
                cava_config = null; # Default: null?
                format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█"]; #!! Required
                framerate = 30; # Default 30?
                hide_on_silence = true; # Default false
                higher_cutoff_freq = 10000; # Default 10000?
                input_delay = 1; # Default 4
                lower_cutoff_freq = 50; # Default 50?
                method = "pipewire"; # Default pulse
                monstercat = true; # Default false?
                noise_reduction = 0.2; # Default 0.77?
                on-click = easyeffects;
                on-scroll-down = "${swayosd-client} --output-volume lower";
                on-scroll-up = "${swayosd-client} --output-volume raise";
                reverse = false; # Default false
                rotate = 180;
                sample_bits = 16; # Default 16?
                sample_rate = 44100; # Default 44100?
                #// sensitivity = 0; # Default 100?
                sleep_timer = 5; # Default 0
                source = "auto"; # Default auto?
                stereo = false; # Default true
                waves = true; # Default false?
              };
          in {
            default = {
              layer = "top";
              position = "bottom";
              reload_style_on_change = true;

              modules-left = [
                "custom/power"
                "custom/inhibitor"
                "custom/vpn"
                "custom/vm"
                (mkIf config.custom.desktops.hyprland.enable "hyprland/workspaces")
                (mkIf config.custom.desktops.niri.enable "niri/workspaces")
              ];

              modules-center = [
                #// "cava#forward"
                "clock#date"

                # BUG: Padding modifiers not currently supported, so use custom module
                # https://github.com/Alexays/Waybar/issues/1469 et al.
                #// "clock#time"
                "custom/time"

                "custom/weather"
                #// "cava#reverse"
              ];

              modules-right = [
                "mpris"
                "tray"
                "custom/equalizer"
                "wireplumber"
                "bluetooth"
                "network"
                "power-profiles-daemon"
                "battery"
              ];

              # https://github.com/Alexays/Waybar/wiki/Module:-Battery
              battery =
                common
                // {
                  format = "{icon} {power:.0f}W";
                  format-icons = ["󰂃" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
                  interval = 5; # Seconds

                  states = {
                    critical = 15; # Percent
                    warning = 30; # Percent
                  };
                };

              # https://github.com/Alexays/Waybar/wiki/Module:-Bluetooth
              bluetooth =
                common
                // {
                  format-connected = "󰂱";
                  format-disabled = "󰂲";
                  format-off = "󰂲";
                  format-on = "󰂯";
                  on-click = "${rfkill} toggle bluetooth";
                  on-click-middle = "${bluetoothctl} disconnect";
                  on-click-right = blueberry;
                };

              # https://github.com/Alexays/Waybar/wiki/Module:-Cava
              "cava#forward" = cava;
              "cava#reverse" = cava // {reverse = true;};

              # https://github.com/Alexays/Waybar/wiki/Module:-Clock
              # https://fmt.dev/latest/syntax/#chrono-format-specifications
              "clock#date" =
                common
                // {
                  format = "{:%a %b %d}";
                  tooltip-format = "{calendar}";
                  on-click-right = gnome-calendar;

                  calendar = {
                    format = {
                      months = "<span color='#eee8d5'>{}</span>";
                      weeks = "<span color='#eee8d5'>{}</span>";
                      weekdays = "<span color='#93a1a1'>{}</span>";
                      days = "<span color='#586e75'>{}</span>";
                      today = "<span color='#eee8d5'>{}</span>";
                    };
                  };
                };

              "clock#time" =
                common
                // {
                  format = "<span text_transform='lowercase'>{:%-I:%M%p}</span>";
                  on-click = "${swaync-client} --toggle-panel";
                  on-click-right = gnome-clocks;
                };

              # https://github.com/Alexays/Waybar/wiki/Module:-Hyprland
              "hyprland/workspaces" =
                common
                // {
                  format = "{icon}";

                  format-icons = {
                    android = "";
                    dropdown = "󰞷";
                    game = "󰊴";
                    hidden = "";
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

                  show-special = true;
                };

              # https://github.com/Alexays/Waybar/wiki/Module:-Idle-Inhibitor
              # BUG: Not currently compatible with other inhibit activations
              # https://github.com/Alexays/Waybar/issues/690
              idle_inhibitor =
                common
                // {
                  format = "{icon}";

                  format-icons = {
                    activated = "󰅶";
                    deactivated = "󰾪";
                  };
                };

              # BUG: Widget stays after last player closes
              # https://github.com/Alexays/Waybar/issues/3107
              # https://github.com/Alexays/Waybar/wiki/Module:-MPRIS
              mpris =
                common
                // {
                  format = "{player_icon} {dynamic}";
                  format-paused = "{status_icon} {dynamic}";
                  artist-len = 32; # Characters
                  title-len = 32; # Characters
                  dynamic-len = 64; # Characters
                  dynamic-importance-order = ["artist" "title"];
                  dynamic-order = ["artist" "title"];
                  dynamic-separator = " 󰧟 ";

                  player-icons = {
                    default = "󰎈";
                    chromium = "";
                    firefox = "";
                  };

                  status-icons = {
                    paused = "";
                    stopped = "";
                  };

                  # TODO: on-click focus currently playing window
                  #// on-click = "";

                  on-click-middle =
                    if config.custom.desktop == "niri"
                    then ''${niri} msg action close-window --id "$(${niri} msg -j windows | ${jq} '.[] | select(.app_id == "YouTube Music").id')"''
                    else "";

                  on-scroll-down = "${swayosd-client} --output-volume lower";
                  on-scroll-up = "${swayosd-client} --output-volume raise";
                };

              # https://github.com/Alexays/Waybar/wiki/Module:-Network
              network =
                common
                // {
                  format = "{icon}";

                  format-icons = {
                    disabled = "";
                    disconnected = "";
                    ethernet = "󰈀";
                    linked = "";
                    wifi = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
                  };

                  on-click = network;
                  on-click-right = nm-connection-editor;
                };

              # https://github.com/Alexays/Waybar/wiki/Module:-Niri
              "niri/workspaces" =
                common
                // {
                  format = "{icon}";

                  # format-icons = {
                  #   "1" = "";
                  #   "2" = "";
                  #   "3" = "";
                  # };
                };

              # https://github.com/Alexays/Waybar/wiki/Module:-PowerProfilesDaemon
              power-profiles-daemon =
                common
                // {
                  format = "{icon}";

                  format-icons = {
                    default = "";
                    performance = "";
                    balanced = "";
                    power-saver = "";
                  };

                  tooltip = false;
                };

              # https://github.com/Alexays/Waybar/wiki/Module:-WirePlumber
              wireplumber =
                common
                // {
                  format = "{icon} {volume}%";
                  format-icons = ["󰕿" "󰖀" "󰕾"];
                  format-muted = "󰸈";
                  on-click = "${swayosd-client} --output-volume mute-toggle";
                  on-click-right = pwvucontrol;
                  on-scroll-down = "${swayosd-client} --output-volume lower";
                  on-scroll-up = "${swayosd-client} --output-volume raise";
                };

              # https://github.com/Alexays/Waybar/wiki/Module:-Custom
              "custom/equalizer" =
                common
                // {
                  exec = pkgs.writeShellScript "equalizer.sh" ''
                    ${echo} 󰺢
                    ${echo} "$(${cat} ~/.audio)"
                    ${echo} "$(${cat} ~/.audio | ${tr} '[:upper:]' '[:lower:]')"
                  '';

                  interval = 5; # Seconds
                  on-click = audio;
                  on-click-right = easyeffects;
                };

              "custom/inhibitor" =
                common
                // {
                  exec = pkgs.writeShellScript "inhibitor.sh" ''
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

                  interval = 5; # Seconds
                  on-click = inhibit;
                };

              "custom/power" =
                common
                // {
                  format = "";
                  on-click = "${systemctl} poweroff";
                  on-click-middle = "${loginctl} terminate-session ${config.custom.username}";
                  on-click-right = "${systemctl} reboot";
                };

              "custom/time" =
                common
                // {
                  exec = "${date} '+%-I:%M%P'";
                  interval = 60; # Seconds
                  on-click = "${swaync-client} --toggle-panel";
                  on-click-right = gnome-clocks;
                };

              "custom/vm" =
                common
                // {
                  exec = pkgs.writeShellScript "vm.sh" ''
                    case "$(${virsh} domstate myndows)" in
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

                  interval = 5;

                  on-click = ''${remote} --vm --client sdl-freerdp --username Myned --password "$(${cat} ${config.age.secrets."desktop/vm/myndows.pass".path})" myndows'';

                  on-click-middle = "${virsh} shutdown myndows";
                  on-click-right = virt-manager;
                };

              "custom/vpn" =
                common
                // {
                  exec = pkgs.writeShellScript "vpn.sh" ''
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

                  interval = 5; # Seconds
                  on-click = "${vpn} mypi3";
                };

              # https://github.com/bjesus/wttrbar
              "custom/weather" =
                common
                // {
                  exec = lib.strings.concatStringsSep " " [
                    wttrbar
                    "--ampm"
                    "--fahrenheit"
                    "--hide-conditions"
                    "--main-indicator temp_F"
                  ];

                  format = "{}°";
                  interval = 60 * 60; # Seconds
                  return-type = "json";
                  on-click-right = gnome-weather;
                };
            };
          };
        };
      }
    ];
  };
}
