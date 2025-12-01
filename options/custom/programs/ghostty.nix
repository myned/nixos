{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.ghostty;
  hm = config.home-manager.users.${config.custom.username};

  ghostty = getExe hm.programs.ghostty.package;
in {
  options.custom.programs.ghostty = {
    enable = mkOption {default = false;};
    service = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://ghostty.org/
        programs.ghostty = {
          enable = true;

          # https://ghostty.org/docs/config/reference
          settings = {
            adjust-cell-width = -1;

            # https://ghostty.org/docs/config/reference#adw-toolbar-style
            adw-toolbar-style = "flat";

            # https://ghostty.org/docs/config/reference#confirm-close-surface
            confirm-close-surface = false;

            # https://ghostty.org/docs/config/reference#cursor-style-blink
            cursor-style-blink = false;

            # https://ghostty.org/docs/config/reference#font-family
            #?? ghostty +list-fonts
            #?? ghostty +show-face
            font-family = mkForce ["monospace" "Unifont"]; # Force unifont icons

            # https://ghostty.org/docs/config/reference#freetype-load-flags
            # https://github.com/ghostty-org/ghostty/discussions/3515
            #// freetype-load-flags = "no-force-autohint";

            # https://ghostty.org/docs/help/gtk-single-instance
            gtk-single-instance = true;

            # https://ghostty.org/docs/config/reference#gtk-titlebar
            gtk-titlebar = true;

            # https://ghostty.org/docs/config/reference#mouse-hide-while-typing
            mouse-hide-while-typing = true;

            # https://ghostty.org/docs/config/reference#mouse-scroll-multiplier
            mouse-scroll-multiplier = 3;

            # https://ghostty.org/docs/config/reference#scrollback-limit
            #!! Per terminal surface
            scrollback-limit = 1 * 1024 * 1024 * 1024; # GiB

            # https://ghostty.org/docs/config/reference#shell-integration-features
            shell-integration-features = "no-cursor";

            # https://ghostty.org/docs/config/reference#window-decoration
            window-decoration = "auto";

            # https://ghostty.org/docs/config/reference#window-new-tab-position
            window-new-tab-position = "end";

            # https://ghostty.org/docs/config/reference#window-padding-balance
            # BUG: Not always distributed equally
            # https://github.com/ghostty-org/ghostty/discussions/3941
            window-padding-balance = true;

            # https://ghostty.org/docs/config/reference#window-padding-x
            window-padding-x = 8;
            window-padding-y = 4;
          };
        };

        # HACK: Launch in background to decrease GTK startup delay
        # https://github.com/ghostty-org/ghostty/discussions/2978
        systemd.user.services = mkIf cfg.service {
          ghostty = {
            Unit = {
              Description = "Ghostty Background Service";
              After = ["xdg-desktop-autostart.target"];
            };

            Service = {
              BusName = "com.mitchellh.ghostty";
              ExecStart = "${ghostty} --initial-window=false --quit-after-last-window-closed=false";
              Type = "dbus";
            };

            Install = {
              WantedBy = ["xdg-desktop-autostart.target"];
            };
          };
        };

        # https://nix-community.github.io/stylix/options/modules/ghostty.html
        stylix.targets.ghostty.enable = true;
      }
    ];
  };
}
