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
      agenix.enable = mkDefault true;
      dev.enable = mkDefault true;
      mnt.enable = mkDefault true;
      nixos.enable = mkDefault true;
    };
  };
}
