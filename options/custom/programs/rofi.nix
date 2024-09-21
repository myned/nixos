{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.rofi;
in {
  options.custom.programs.rofi.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    #!! Creates package derivation
    #?? config.home-manager.users.${config.custom.username}.programs.rofi.finalPackage
    # https://github.com/lbonn/rofi
    programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland; # Wayland fork

      # TODO: Look into rofi plugins
      plugins = with pkgs; [
        rofi-rbw # Bitwarden
        rofimoji # Character picker

        # TODO: Remove when rofi v1.7.6 released
        # Build against rofi-wayland due to ABI incompatibility with upstream
        # https://github.com/lbonn/rofi/issues/96
        # https://github.com/NixOS/nixpkgs/issues/298539
        (rofi-calc.override {rofi-unwrapped = rofi-wayland-unwrapped;}) # Calculator
        (rofi-top.override {rofi-unwrapped = rofi-wayland-unwrapped;}) # System monitor
      ];

      #?? rofi-theme-selector
      theme = "custom";
      font = "${config.custom.font.monospace} 16";

      # https://github.com/davatorium/rofi/blob/next/CONFIG.md
      extraConfig = {
        modi = "drun,run,calc";
        matching = "prefix"; # Match beginning of words
        drun-display-format = "{name}"; # Display only names
        drun-match-fields = "name"; # Disable matching of invisible desktop attributes
      };
    };

    # https://github.com/davatorium/rofi/blob/next/doc/rofi-theme.5.markdown
    # https://github.com/davatorium/rofi/blob/next/themes/paper-float.rasi
    # TODO: Clean up theme
    home.file.".config/rofi/custom.rasi".text = ''
      * {
          background: #073642ff;
          alternate:  #002b36ff;
          text: #eee8d5ff;
          accent:  #d33682ff;

          spacing: 2;
          text-color: @text;
          background-color: #00000000;
          border-color: @accent;
          anchor: north;
          location: center;
      }
      window {
          transparency: "real";
          background-color: #00000000;
          border: 0;
          padding: 0% 0% 1em 0%;
          x-offset: 0;
          y-offset: -10%;
      }
      mainbox {
          padding: 0px;
          border: 0;
          spacing: 1%;
      }
      message {
          border: 2px;
          padding: 1em;
          background-color: @background;
          text-color: @text;
      }
      textbox normal {
          text-color: @text;
          padding: 0;
          border: 0;
      }
      listview {
          fixed-height: 1;
          border: 2px;
          padding: 1em;
          reverse: false;

          columns: 1;
          background-color: @background;
      }
      element {
          border: 0;
          padding: 2px;
          highlight: bold ;
      }
      element-text {
          background-color: inherit;
          text-color:       inherit;
      }
      element normal.normal {
          text-color: @text;
          background-color: @background;
      }
      element normal.urgent {
          text-color: @text;
          background-color: @background;
      }
      element normal.active {
          text-color: @text;
          background-color: @background;
      }
      element selected.normal {
          text-color: @text;
          background-color: @accent;
      }
      element selected.urgent {
          text-color: @text;
          background-color: @accent;
      }
      element selected.active {
          text-color: @text;
          background-color: @accent;
      }
      element alternate.normal {
          text-color: @text;
          background-color: @alternate;
      }
      element alternate.urgent {
          text-color: @text;
          background-color: @alternate;
      }
      element alternate.active {
          text-color: @text;
          background-color: @alternate;
      }
      scrollbar {
          border: 0;
          padding: 0;
      }
      inputbar {
          spacing: 0;
          border: 2px;
          padding: 0.5em 1em;
          background-color: @background;
          index: 0;
      }
      inputbar normal {
          foreground-color: @text;
          background-color: @background;
      }
      mode-switcher {
          border: 2px;
          padding: 0.5em 1em;
          background-color: @background;
          index: 10;
      }
      button selected {
          text-color: @accent;
      }
      inputbar {
          children:   [ prompt,textbox-prompt-colon,entry,case-indicator ];
      }
      textbox-prompt-colon {
          expand:     false;
          str:        ":";
          margin:     0px 0.3em 0em 0em ;
          text-color: @text;
      }
      error-message {
          border: 2px;
          padding: 1em;
          background-color: @background;
          text-color: @text;
      }
    '';
  };
}
