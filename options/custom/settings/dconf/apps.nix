{ config, lib, ... }:

with lib;

let
  cfg = config.custom.settings.dconf.apps;
in
{
  options.custom.settings.dconf.apps.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://nix-community.github.io/home-manager/index.xhtml#sec-option-types
    # https://docs.gtk.org/glib/struct.Variant.html
    # https://docs.gtk.org/glib/gvariant-format-strings.html
    #?? dconf watch /
    dconf.settings = with config.home-manager.users.${config.custom.username}.lib.gvariant; {
      # BlackBox
      "com/raggesilver/BlackBox" = {
        command-as-login-shell = mkBoolean false;
        context-aware-header-bar = mkBoolean true;
        cursor-blink-mode = mkUint32 0;
        cursor-shape = mkUint32 0;
        delay-before-showing-floating-controls = mkUint32 100;
        easy-copy-paste = mkBoolean false;
        fill-tabs = mkBoolean true;
        floating-controls = mkBoolean true;
        floating-controls-hover-area = mkUint32 10;
        font = mkString "monospace 14";
        headerbar-drag-area = mkBoolean false;
        notify-process-completion = mkBoolean false;
        opacity = mkUint32 100;
        pretty = mkBoolean false;
        remember-window-size = mkBoolean false;
        scrollback-mode = mkInt32 1;
        scrollbar-mode = mkUint32 1;
        show-headerbar = mkBoolean false;
        show-menu-button = mkBoolean false;
        show-scrollbars = mkBoolean true;
        style-preference = mkUint32 0;
        terminal-bell = mkBoolean true;
        terminal-cell-height = mkDouble 1.0;
        terminal-cell-width = mkDouble 1.0;
        theme-bold-is-bright = mkBoolean false;
        theme-dark = mkString "Solarized Dark";
        theme-light = mkString "Solarized Light";
        use-custom-command = mkBoolean false;
        use-overlay-scrolling = mkBoolean true;
        working-directory-mode = mkUint32 1;

        #?? (uuuu)
        terminal-padding = mkTuple [
          (mkUint32 4)
          (mkUint32 4)
          (mkUint32 4)
          (mkUint32 4)
        ];
      };

      # Dconf Editor
      "ca/desrt/dconf-editor" = {
        show-warning = mkBoolean false;
      };

      # EasyEffects
      "com/github/wwmm/easyeffects/spectrum" = {
        show = false;
      };

      # GNOME
      "org/gnome/desktop/interface" = {
        cursor-blink = mkBoolean false;
        gtk-enable-primary-paste = mkBoolean false;
        color-scheme = mkString "prefer-dark";
        monospace-font-name = mkString "monospace 14";
      };

      # GNOME Files
      "org/gtk/gtk4/settings/file-chooser" = {
        show-hidden = mkBoolean true;
      };

      "org/gnome/nautilus/preferences" = {
        show-create-link = mkBoolean true;
        show-delete-permanently = mkBoolean true;
        click-policy = mkString "single";
        default-folder-viewer = mkString "list-view";
      };

      "org/gnome/nautilus/list-view" = {
        #?? [as]
        default-column-order = mkArray type.string [
          "name"
          "type"
          "size"
          "owner"
          "group"
          "permissions"
          "where"
          "date_modified"
          "date_modified_with_time"
          "date_accessed"
          "date_created"
          "recency"
          "detailed_type"
        ];

        #?? [as]
        default-visible-columns = mkArray type.string [
          "name"
          "type"
          "size"
          "date_modified"
        ];
      };

      # GNOME Terminal
      "org/gnome/terminal/legacy/profiles:/:8856406f-96d1-4284-8428-2329d2458b55" = {
        scrollback-unlimited = mkBoolean true;
      };

      # GNOME Text Editor
      "org/gnome/TextEditor" = {
        highlight-current-line = mkBoolean true;
        restore-session = mkBoolean false;
        show-line-numbers = mkBoolean true;
        show-map = mkBoolean true;
        tab-width = mkUint32 2;
        indent-style = mkString "space";
        style-scheme = mkString "solarized-dark";
        style-variant = mkString "dark";

        # Not exposed in UI
        # https://gitlab.gnome.org/GNOME/gnome-text-editor/-/commit/416a65af17f6b759721ef4606f7b7805fe7af67a
        #?? [as]
        draw-spaces = mkArray type.string [
          "space"
          "tab"
          "nbsp"
          "trailing"
        ];
      };

      # Virtual Machine Manager
      "org/virt-manager/virt-manager" = {
        xmleditor-enabled = mkBoolean true;
      };

      "org/virt-manager/virt-manager/confirm" = {
        forcepoweroff = mkBoolean false;
      };

      "org/virt-manager/virt-manager/connections" = {
        #?? [as]
        autoconnect = mkArray type.string [ "qemu:///system" ];
        uris = mkArray type.string [ "qemu:///system" ];
      };

      "org/virt-manager/virt-manager/console" = {
        auto-redirect = mkBoolean false;
        resize-guest = mkInt32 1;
        scaling = mkInt32 2;
      };

      "org/virt-manager/virt-manager/new-vm" = {
        cpu-default = mkString "host-passthrough";
        firmware = mkString "uefi";
        graphics-type = mkString "spice";
        storage-format = mkString "qcow2";
      };

      "org/virt-manager/virt-manager/stats" = {
        enable-cpu-poll = mkBoolean false;
        update-interval = mkInt32 5;
      };

      "org/virt-manager/virt-manager/vmlist-fields" = {
        cpu-usage = mkBoolean false;
      };
    };
  };
}
