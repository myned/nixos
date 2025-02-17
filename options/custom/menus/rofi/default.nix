{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.menus.rofi;
  hm = config.home-manager.users.${config.custom.username};

  bash = getExe pkgs.bash;
  cliphist = getExe hm.services.cliphist.package;
  echo = getExe' pkgs.coreutils "echo";
  networkmanager_dmenu = getExe pkgs.networkmanager_dmenu;
  notify-send = getExe pkgs.libnotify;
  pkill = getExe' pkgs.procps "pkill";
  rofi = getExe hm.programs.rofi.finalPackage;
  rofi-rbw = getExe pkgs.rofi-rbw;
  rofimoji = getExe pkgs.rofimoji;
  wl-copy = getExe' pkgs.wl-clipboard "wl-copy";
in {
  options.custom.menus.rofi = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    custom = mkIf (config.custom.menu == "rofi") {
      menus = mapAttrsRecursive (path: value: toString (pkgs.writeShellScript (concatStringsSep "-" (["menus"] ++ path)) value)) {
        default.show = "${pkill} --exact rofi || ${rofi} -modes drun -show drun -show-icons";
        calculator.show = ''${pkill} --exact rofi || ${rofi} -modes calc -show calc -no-history -calc-error-color '#dc322f' -calc-command "${echo} -n '{result}' | ${wl-copy}"'';

        clipboard = {
          show = "${pkill} --exact rofi || ${rofi} -modes clipboard -show clipboard -show-icons";
          clear = "${cliphist} wipe && ${notify-send} '> cliphist' 'Clipboard cleared' --urgency low";
          clear-silent = "${cliphist} wipe";
        };

        dmenu.show = "${pkill} --exact rofi || ${rofi} -dmenu";
        emoji.show = "${pkill} --exact rofi || ${rofimoji} --prompt 󰱰";
        network.show = "${pkill} --exact rofi || ${networkmanager_dmenu}";
        search.show = "";
        vault.show = "${pkill} --exact rofi || ${rofi-rbw}";
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
