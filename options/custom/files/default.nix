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

  config.custom.files = mkIf config.custom.default {
    agenix.enable = true;
    dev.enable = true;
    mnt.enable = true;
    nixos.enable = true;
  };
}
