{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.files;
in {
  options.custom.files = {
    enable = mkEnableOption "files";
  };

  config = mkIf cfg.enable {
    custom.files = {
      agenix.enable = true;
      dev.enable = true;
      mnt.enable = true;
      nixos.enable = true;
    };
  };
}
