{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.ryzenadj;
in {
  options.custom.programs.ryzenadj.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ryzenadj];
    hardware.cpu.amd.ryzen-smu.enable = true;
  };
}
