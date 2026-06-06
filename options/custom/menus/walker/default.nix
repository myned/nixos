{
  config,
  lib,
  options,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.menus.walker;
  hm = config.home-manager.users.${config.custom.username};

  notify-send = getExe pkgs.libnotify;
  rm = getExe' pkgs.coreutils "rm";
  walker = getExe hm.services.walker.package;
in {
  options.custom.menus.walker = {
    enable = mkEnableOption "walker";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      custom = mkIf (config.custom.menu == "walker") {
        # TODO: Update commands
        menus = mapAttrsRecursive (path: value: toString (pkgs.writeShellScript (concatStringsSep "-" (["menus"] ++ path)) value)) {
          default.show = walker;
          calculator.show = "${walker} --provider=calc";

          clipboard = {
            show = "${walker} --provider=clipboard";
            clear = "${rm} ~/.cache/elephant/clipboard.gob && ${notify-send} '> walker' 'Clipboard cleared' --urgency low";
            clear-silent = "${rm} ~/.cache/elephant/clipboard.gob";
          };

          dmenu.show = "${walker} --dmenu";
          emoji.show = "${walker} --provider=symbols";
          search.show = "${walker} --provider=websearch";
          vault.show = "";
        };
      };

      home-manager.sharedModules = [
        {
          # https://benz.gitbook.io/walker/
          # https://github.com/abenz1267/walker
          # https://github.com/abenz1267/walker?tab=readme-ov-file#-install-using-nix-
          services.walker = {
            enable = true;
            systemd.enable = true; #?? systemctl --user restart walker.service

            # https://github.com/abenz1267/walker/blob/master/resources/config.toml
            settings = {
              click_to_close = false;
              close_when_open = true;
              hide_quick_activation = true;
              force_keyboard_focus = true;
            };
          };
        }
      ];
    })
  ];
}
