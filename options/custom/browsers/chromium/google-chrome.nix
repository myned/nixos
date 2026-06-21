{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.browsers.google-chrome;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.browsers.google-chrome = {
    enable = mkEnableOption "google-chrome";
  };

  config = mkIf cfg.enable {
    custom.browsers.programs.google-chrome = {
      appId = "google-chrome";
      command = ["google-chrome" "--profile-directory=Default"];
      commandWork = ["google-chrome" "--profile-directory=Profile 1" "--window-name=Work"];
      desktop = "google-chrome.desktop";
    };

    custom.browsers.chromium.enable = true; # Required for policy module

    nixpkgs.overlays = [
      (final: prev: {
        google-chrome = prev.google-chrome.override {
          commandLineArgs = with config.custom.browsers.programs; chromium.commandLineArgs ++ google-chrome.commandLineArgs;
        };
      })
    ];

    home-manager.sharedModules = [
      {
        # https://www.google.com/chrome/
        programs.google-chrome.enable = true;
      }
    ];
  };
}
