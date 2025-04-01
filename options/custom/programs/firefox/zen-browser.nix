{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.zen-browser;
  hm = config.home-manager.users.${config.custom.username};
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

            profiles.default = {
              settings = {
                "zen.pinned-tab-manager.close-shortcut-behavior" = "reset-unload-switch";
                "zen.pinned-tab-manager.restore-pinned-tabs-to-pinned-url" = false;
                "zen.splitView.change-on-hover" = true;
                "zen.tab-unloader.enabled" = false;
                "zen.tab-unloader.timeout-minutes" = 60;
                "zen.theme.accent-color" = "#d33682";
                "zen.theme.color-prefs.colorful" = false;
                "zen.theme.color-prefs.use-workspace-colors" = true;
                "zen.theme.pill-button" = true;
                "zen.urlbar.behavior" = "normal";
                "zen.urlbar.replace-newtab" = false;
                "zen.view.compact.hide-toolbar" = true;
                "zen.view.show-newtab-button-top" = false;
                "zen.view.sidebar-expanded" = true;
                "zen.view.use-single-toolbar" = false;
                "zen.welcome-screen.enabled" = false;
                "zen.welcome-screen.seen" = true;
                "zen.workspaces.container-specific-essentials-enabled" = false;
                "zen.workspaces.force-container-workspace" = true;
                "zen.workspaces.hide-deactivated-workspaces" = true;
                "zen.workspaces.hide-default-container-indicator" = false;
                "zen.workspaces.individual-pinned-tabs" = true;
                "zen.workspaces.show-icon-strip" = false;
                "zen.workspaces.show-workspace-indicator" = true;
              };
            };
          }
        ];

        home = {
          activation = {
            # HACK: Zen only recognizes profiles that include the ZenAvatarPath key
            update-zen-browser-profile = hm.lib.dag.entryAfter ["writeBoundary"] ''
              run sed -i \
                's|\[Profile\([0-9]*\)\]|[Profile\1]\nZenAvatarPath=chrome://browser/content/zen-avatars/avatar-95.svg|' \
                "$HOME/.zen/profiles.ini"
            '';
          };

          file = let
            sync = source: {
              source = hm.lib.file.mkOutOfStoreSymlink "${config.custom.sync}/${source}";
              force = true;
            };
          in {
            ".zen/profiles.ini".force = true;

            #!! Imperative synced files
            ".zen/default/extension-preferences.json" = sync "linux/config/firefox/extension-preferences.json";
            ".zen/default/extension-settings.json" = sync "linux/config/firefox/extension-settings.json";
            ".zen/default/zen-keyboard-shortcuts.json" = sync "linux/config/zen/zen-keyboard-shortcuts.json";
            ".zen/default/zen-themes.json" = sync "linux/config/zen/zen-themes.json";
          };
        };
      }
    ];
  };
}
