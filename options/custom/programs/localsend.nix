{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.localsend;
in {
  options.custom.programs.localsend.enable = mkOption {default = false;};

  config =
    if (versionAtLeast version "24.11")
    then
      (mkIf cfg.enable {
        # https://github.com/localsend/localsend
        programs.localsend = {
          enable = true;
          openFirewall = true;
        };
      })
    else {};
}
