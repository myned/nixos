{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.kmscon;
in {
  options.custom.services.kmscon = {
    enable = mkEnableOption "kmscon";
  };

  config = mkIf cfg.enable {
    # https://github.com/Aetf/kmscon
    # https://wiki.archlinux.org/title/KMSCON
    services.kmscon = {
      enable = true;
    };
  };
}
