{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.menus.rofi;
  hm = config.home-manager.users.${config.custom.username};

  cliphist = getExe hm.services.cliphist.package;
  networkmanager_dmenu = getExe pkgs.networkmanager_dmenu;
  notify-send = getExe pkgs.libnotify;
  pkill = getExe' pkgs.procps "pkill";
  rofi = getExe hm.programs.rofi.finalPackage;
  rofi-rbw = getExe pkgs.rofi-rbw;
  rofimoji = getExe pkgs.rofimoji;
in {
  options.custom.menus.rofi = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    custom = mkIf (config.custom.menu == "rofi") {
      menus = let
        quit = "${pkill} --exact rofi";
      in {
        show = "${quit} || ${rofi} -show drun -show-icons";
        calculator.show = "${quit} || ${rofi} -show calc";

        clipboard = {
          show = "${quit} || ${rofi} -show clipboard -show-icons";
          clear = "${cliphist} wipe && ${notify-send} '> cliphist' 'Clipboard cleared' --urgency low";
          clear-silent = "${cliphist} wipe";
        };

        dmenu.show = "${quit} || ${rofi} -dmenu";
        emoji.show = "${quit} || ${rofimoji} --prompt 󰱰";
        network.show = "${quit} || ${rofi} -dmenu -p 󰛳";
        search.show = "";
        vault.show = "${quit} || ${rofi-rbw} --prompt 󰌾";
      };

      services = {
        cliphist.enable = true;
      };
    };

    environment.systemPackages = [
      pkgs.rofimoji # https://github.com/fdw/rofimoji
    ];

    home-manager.sharedModules = [
      {
        #!! Creates package derivation
        #?? hm.programs.rofi.finalPackage
        # https://github.com/davatorium/rofi
        programs.rofi = {
          enable = true;

          # https://github.com/lbonn/rofi
          package = pkgs.rofi-wayland; # Wayland fork

          plugins = with pkgs; [
            rofi-calc # https://github.com/svenstaro/rofi-calc
          ];

          # https://davatorium.github.io/rofi/themes/themes/
          #?? rofi-theme-selector
          theme = "custom";

          # https://davatorium.github.io/rofi/current/rofi.1/
          # https://www.nerdfonts.com/cheat-sheet
          extraConfig = {
            combi-hide-mode-prefix = true;
            combi-modes = ["drun" "run"];
            cycle = false;
            display-calc = "";
            display-clipboard = "";
            display-combi = "";
            display-dmenu = "󰗧";
            display-drun = "󱗼";
            display-keys = "󰌌";
            display-run = "";
            display-ssh = "";
            drun-display-format = "{name}"; # Display only names
            drun-match-fields = "name"; # Disable matching of invisible desktop attributes
            matching = "prefix"; # Match beginning of words

            # https://davatorium.github.io/rofi/current/rofi.1/#available-modes
            modes = [
              "calc"
              "clipboard"
              "combi"
              "drun"
              "keys"
              "run"
              "ssh"
            ];
          };
        };

        xdg.configFile = {
          # https://davatorium.github.io/rofi/current/rofi-theme.5/
          "rofi/custom.rasi".text = ''
            ${readFile ./custom.rasi}

            window, inputbar {
              border: ${toString config.custom.border}px;
            }
          '';

          # https://davatorium.github.io/rofi/current/rofi-script.5/
          # https://github.com/sentriz/cliphist?tab=readme-ov-file#picker-examples
          "rofi/scripts/clipboard" = {
            #// source = getExe' hm.services.cliphist.package "cliphist-rofi-img";

            # HACK: Cannot easily hide index via display-columns without dmenu mode
            # https://github.com/sentriz/cliphist/issues/130
            # https://github.com/davatorium/rofi/discussions/1993#discussioncomment-9971764
            # https://github.com/sentriz/cliphist/pull/124
            source = getExe (pkgs.writeShellApplication {
              name = "clipboard.sh";
              runtimeInputs = with pkgs; [coreutils gnused wl-clipboard];
              text = readFile ./clipboard.sh;
            });
          };
        };
      }
    ];
  };
}
