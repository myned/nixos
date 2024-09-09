{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  poetry = "${pkgs.poetry}/bin/poetry";

  cfg = config.custom.services.modufur;
in
{
  options.custom.services.modufur.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    #!! Imperative source control
    #?? git clone https://github.com/Myned/modufur
    systemd.user.services.modufur = {
      description = [ "Modufur" ];
      requires = [ "default.target" ];
      after = [ "default.target" ];
      wantedBy = [ "default.target" ];

      serviceConfig = {
        WorkingDirectory = [ "/home/myned/.git/modufur" ];
        ExecStart = [ "${poetry}/bin/poetry run python -OO run.py >&2" ];
      };
    };
  };
}
