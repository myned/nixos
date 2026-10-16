{
  config,
  inputs,
  lib,
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
  };
}
