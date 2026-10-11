{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.musnix;
in {
  # https://github.com/musnix/musnix
  imports = [inputs.musnix.nixosModules.musnix];

  options.custom.settings.musnix = {
    enable = mkEnableOption "musnix";
  };

  config = mkIf cfg.enable {
    musnix.enable = true;

    # Plugins
    environment.systemPackages = with pkgs.unstable; [
      jc303 # https://github.com/midilab/jc303
    ];
  };
}
