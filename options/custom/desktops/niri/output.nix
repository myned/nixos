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
      programs.niri.settings.outputs = mapAttrs (_: output:
        with output; {
          backdrop-color = "#073642";
          background-color = "#073642";
          scale = scale + 0.0;

          mode = {
            width = builtins.floor width;
            height = builtins.floor height;
            refresh = finalRefresh + 0.0;
          };

          position = {
            x = builtins.floor x;
            y = builtins.floor y;
          };

          variable-refresh-rate =
            if vrr
            then "on-demand" #!! Requires window-rule
            else false;
        })
      config.custom.settings.hardware.outputs;
    };
  };
}
