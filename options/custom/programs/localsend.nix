{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.localsend;
in {
  options.custom.programs.localsend = {
    enable = mkEnableOption "localsend";
  };

  config = mkIf cfg.enable {
    # https://github.com/localsend/localsend
    programs.localsend = {
      enable = true;
      openFirewall = true;
    };
  };
}
