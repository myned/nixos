{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri.output;
in {
  options.custom.desktops.niri.output = {
    enable = mkEnableOption "output";
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://github.com/YaLTeR/niri/wiki/Configuration:-Outputs
      # https://github.com/sodiboo/niri-flake/blob/main/docs.md#programsnirisettingsoutputs
      #?? niri msg outputs
      programs.niri.settings.outputs =
        mapAttrs (name: value: {
          backdrop-color = "#073642";
          background-color = "#073642";
          position = value.position;

          mode = {
            width = value.width;
            height = value.height;
            refresh = value.refresh + 0.0;
          };

          variable-refresh-rate =
            if value.vrr
            then "on-demand" #!! Requires window-rule
            else false;
        })
        config.custom.settings.hardware.display.outputs;
    };
  };
}
