{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.slurp;
in {
  options.custom.programs.slurp.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/emersion/slurp
    # https://github.com/emersion/slurp/blob/master/slurp.1.scd
    home.sessionVariables.SLURP_ARGS = lib.concatStringsSep " " [
      "'-B 00000000"
      "-b 00000000"
      "-c d33682"
      #// "-s d3368240"
      "-w 2'"
    ];
  };
}
