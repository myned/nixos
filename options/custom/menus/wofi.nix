{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.menus.wofi;
in {
  options.custom.menus.wofi.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://hg.sr.ht/~scoopta/wofi
    programs.wofi = {
      enable = true;

      #?? man 5 wofi
      settings = {
        allow_images = true;

        # TODO: Fix line height
        # BUG: Not dynamic
        # https://todo.sr.ht/~scoopta/wofi/93
        # dynamic_lines = true;

        hide_scroll = true;
        insensitive = true;
        no_actions = true;
        lines = 6;
        matching = "multi-contains";

        # BUG: Prompt only displayed without textbox focus
        # https://todo.sr.ht/~scoopta/wofi/169
        prompt = "";

        # Fix flickering on open
        # https://todo.sr.ht/~scoopta/wofi/183
        width = 1000;
        # height = 500;
      };

      # https://cloudninja.pw/docs/wofi.html
      style = ''
        * {
          padding: 2px;
          border-radius: 20px;
        }

        window {
          border: 2px #073642 solid;
        }

        #entry:selected {
          outline: none;
        }
      '';
    };

    # https://nix-community.github.io/stylix/options/modules/wofi.html
    stylix.targets.wofi.enable = false;
  };
}
