{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.ssh;
in {
  options.custom.programs.ssh.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # Disable prompt for new hosts
    # MitM warning is still active
    programs.ssh.extraConfig = ''
      StrictHostKeyChecking no
    '';
  };
}
