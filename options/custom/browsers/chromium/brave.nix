{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.browsers.brave;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.browsers.brave = {
    enable = mkEnableOption "brave";
  };

  config = mkIf cfg.enable {
    custom.browsers.programs.brave = {
      appId = "brave";
      command = "brave";
      desktop = "brave.desktop";
    };

    custom.browsers.chromium.enable = true; # Required for policy module

    nixpkgs.overlays = [
      (final: prev: {
        brave = prev.brave.override {
          commandLineArgs = with config.custom.browsers.programs; chromium.commandLineArgs ++ brave.commandLineArgs;
        };
      })
    ];

    home-manager.sharedModules = [
      {
        # https://brave.com/
        programs.brave.enable = true;
      }
    ];
  };
}
