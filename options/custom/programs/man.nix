{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.man;
in {
  options.custom.programs.man.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # Enable as much offline docs as possible
    # https://wiki.nixos.org/wiki/Man_pages
    documentation = {
      dev.enable = true; # Library manpages

      man = {
        generateCaches = true; # Index manpages for search
        man-db.enable = false; # !! Hangs on building man-cache
        mandoc.enable = true;
      };
    };
  };
}
