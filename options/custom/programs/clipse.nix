{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.clipse;
in {
  options.custom.programs.clipse.enable = mkOption {default = false;};

  config = {
    # https://github.com/savedra1/clipse
    environment.systemPackages = with pkgs; [
      clipse
      wl-clipboard
      xclip
    ];

    home-manager.users.${config.custom.username} = mkIf cfg.enable {
      # https://github.com/savedra1/clipse?tab=readme-ov-file#configuration
      xdg.configFile."clipse/config.json".text = ''
        {
          "historyFile": "clipboard_history.json",
          "maxHistory": 50,
          "allowDuplicates": false,
          "themeFile": "custom_theme.json",
          "tempDir": "tmp_files",
          "logFile": "clipse.log",
          "imageDisplay": {
            "type": "kitty",
            "scaleX": 9,
            "scaleY": 9,
            "heightCut": 2
          }
        }
      '';
    };
  };
}
