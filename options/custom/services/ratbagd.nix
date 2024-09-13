{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.ratbagd;
in {
  options.custom.services.ratbagd.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://github.com/libratbag/libratbag
    # https://github.com/libratbag/piper
    services.ratbagd.enable = true;
    environment.systemPackages = with pkgs; [piper];
  };
}
