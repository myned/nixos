{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.adb;
in {
  options.custom.programs.adb.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Android
    # https://developer.android.com/tools/adb
    programs.adb.enable = true;
    users.users.${config.custom.username}.extraGroups = ["adbusers"];
  };
}
