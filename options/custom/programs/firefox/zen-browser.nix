{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.zen-browser;
in {
  options.custom.programs.zen-browser = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://zen-browser.app/
        # https://github.com/youwen5/zen-browser-flake
        programs.zen-browser = mkMerge [
          (import ./.common.nix {
            inherit config inputs lib pkgs;

            # TODO: Revisit Zen themes
            theme = false;
          })

          {
            enable = true;

            profiles.default.settings = {
              "zen.pinned-tab-manager.close-shortcut-behavior" = "reset-unload-switch";
              "zen.pinned-tab-manager.restore-pinned-tabs-to-pinned-url" = true;
              "zen.tab-unloader.timeout-minutes" = 60;
              "zen.theme.accent-color" = "#d33682";
              "zen.theme.color-prefs.colorful" = false;
              "zen.theme.color-prefs.use-workspace-colors" = true;
              "zen.theme.pill-button" = true;
              "zen.urlbar.replace-newtab" = false;
              "zen.view.compact.hide-toolbar" = true;
              "zen.view.sidebar-expanded" = false;
              "zen.view.use-single-toolbar" = false;
              "zen.welcome-screen.seen" = true;
              "zen.workspaces.container-specific-essentials-enabled" = true;
              "zen.workspaces.force-container-workspace" = true;
              "zen.workspaces.hide-deactivated-workspaces" = true;
              "zen.workspaces.individual-pinned-tabs" = false;
              "zen.workspaces.show-icon-strip" = false;
            };
          }
        ];

        home = {
          activation = {
            # HACK: Zen only recognizes profiles that include the ZenAvatarPath key
            update-zen-browser-profile = lib.home-manager.hm.dag.entryAfter ["writeBoundary"] ''
              run sed -i \
                's|\[Profile\([0-9]*\)\]|[Profile\1]\nZenAvatarPath=chrome://browser/content/zen-avatars/avatar-95.svg|' \
                "$HOME/.zen/profiles.ini"
            '';
          };

          file = {
            ".zen/profiles.ini" = {
              force = true;
            };
          };
        };
      }
    ];
  };
}
