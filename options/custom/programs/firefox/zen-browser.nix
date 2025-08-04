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
    profile = mkOption {default = "default";};
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://zen-browser.app/
      # https://github.com/youwen5/zen-browser-flake
      programs.zen-browser = mkMerge [
        (import ./.common.nix {
          inherit config inputs lib pkgs;
          profile = cfg.profile;
          theme = false;
        })

        {
          enable = true;

          profiles.${cfg.profile} = {
            settings = {
              "browser.toolbars.bookmarks.visibility" = mkForce "always";

              "zen.browser.is-cool" = true;
              "zen.essentials.enabled" = true;
              "zen.glance.activation-method" = "alt";
              "zen.glance.enabled" = true;
              "zen.glance.open-essential-external-links" = true;
              "zen.keyboard.shortcuts.disable-mainkeyset-clear" = true;
              "zen.keyboard.shortcuts.enabled" = true;
              "zen.mediacontrols.enabled" = true;
              "zen.pinned-tab-manager.close-shortcut-behavior" = "reset";
              "zen.pinned-tab-manager.restore-pinned-tabs-to-pinned-url" = false;
              "zen.splitView.change-on-hover" = true;
              "zen.splitView.enable-tab-drop" = true;
              "zen.startup.smooth-scroll-in-tabs" = true;
              "zen.tab-unloader.enabled" = false;
              "zen.tab-unloader.timeout-minutes" = 60;
              "zen.tabs.dim-pending" = true;
              "zen.tabs.rename-tabs" = true;
              "zen.tabs.show-newtab-vertical" = true;
              "zen.tabs.vertical" = true;
              "zen.tabs.vertical.right-side" = false;
              "zen.theme.accent-color" = "#d33682";
              "zen.theme.color-prefs.colorful" = true;
              "zen.theme.color-prefs.use-workspace-colors" = false;
              "zen.theme.essentials-favicon-bg" = true;
              "zen.theme.gradient" = true;
              "zen.theme.gradient.show-custom-colors" = true;
              "zen.theme.pill-button" = true;
              "zen.themes.updated-value-observer" = true;
              "zen.urlbar.behavior" = "normal";
              "zen.urlbar.hide-one-offs" = true;
              "zen.urlbar.replace-newtab" = true;
              "zen.urlbar.show-domain-only-in-sidebar" = true;
              "zen.urlbar.show-protections-icon" = false;
              "zen.view.compact.animate-sidebar" = true;
              "zen.view.compact.color-sidebar" = true;
              "zen.view.compact.color-toolbar" = true;
              "zen.view.compact.hide-tabbar" = true;
              "zen.view.compact.hide-toolbar" = true;
              "zen.view.compact.show-sidebar-and-toolbar-on-hover" = true;
              "zen.view.compact.toolbar-flash-popup" = true;

              # BUG: Rounded corners causes increased GPU usage
              # https://github.com/zen-browser/desktop/issues/6302
              # https://zen-browser.app/mods/c6813222-6571-4ba6-8faf-58f3343324f6/
              "zen.view.experimental-rounded-view" = true;

              "zen.view.grey-out-inactive-windows" = false;
              "zen.view.hide-window-controls" = true;
              "zen.view.show-newtab-button-border-top" = true;
              "zen.view.show-newtab-button-top" = true;
              "zen.view.sidebar-collapsed.hide-mute-button" = true;
              "zen.view.sidebar-expanded" = true;
              "zen.view.use-single-toolbar" = true;
              "zen.watermark.enabled" = true;
              "zen.welcome-screen.enabled" = false;
              "zen.welcome-screen.seen" = true;
              "zen.workspaces.container-specific-essentials-enabled" = false;
              "zen.workspaces.force-container-workspace" = true;
              "zen.workspaces.hide-deactivated-workspaces" = true;
              "zen.workspaces.hide-default-container-indicator" = false;
              "zen.workspaces.individual-pinned-tabs" = true;
              "zen.workspaces.open-new-tab-if-last-unpinned-tab-is-closed" = true;
              "zen.workspaces.show-icon-strip" = false;
              "zen.workspaces.show-workspace-indicator" = false;
              "zen.workspaces.swipe-actions" = true;
              "zen.workspaces.wrap-around-navigation" = true;
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
          ".zen/${cfg.profile}/zen-keyboard-shortcuts.json" = sync "linux/config/zen/zen-keyboard-shortcuts.json";
          ".zen/${cfg.profile}/zen-themes.json" = sync "linux/config/zen/zen-themes.json";
        };
      };

      # https://nix-community.github.io/stylix/options/modules/zen-browser.html
      # stylix.targets.zen-browser = {
      #   enable = false;
      #   profileNames = [cfg.profile];
      # };
    };
  };
}
