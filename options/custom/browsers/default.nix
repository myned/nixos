{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.browsers;
in {
  options.custom.browsers = let
    browserSubmodule = with types;
      submodule ({name, ...}: {
        options = {
          appId = mkOption {
            description = "App ID / class of the browser as seen by the window manager";
            default = name;
            example = "firefox";
            type = str;
          };

          command = mkOption {
            description = "Name of the executable that launches the browser";
            default = name;
            example = "firefox";
            type = str;
          };

          commandLineArgs = mkOption {
            description = "List of command arguments to pass to the browser";
            default = [];
            example = ["--ozone-platform=wayland"];
            type = listOf str;
          };

          desktop = mkOption {
            description = "Name of the desktop file for the browser";
            default = "${name}.desktop";
            example = "firefox.desktop";
            type = str;
          };
        };
      });
  in {
    enable = mkEnableOption "browsers";

    default = mkOption {
      description = "Submodule of the default browser program";
      default = cfg.programs.brave;
      example = cfg.programs.firefox;
      type = browserSubmodule;
    };

    programs = mkOption {
      description = "Submodules of browser programs";
      type = types.attrsOf browserSubmodule;
    };
  };

  config = mkIf cfg.enable {
    custom.browsers = mkDefault {
      brave.enable = true;
      chromium.enable = true;
      google-chrome.enable = true;
      #// firefox.enable = true;
    };
  };
}
