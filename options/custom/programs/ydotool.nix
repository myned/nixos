{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.ydotool;
in {
  options.custom.programs.ydotool = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://github.com/ReimuNotMoe/ydotool
    programs.ydotool.enable = true;
    users.users.${config.custom.username}.extraGroups = ["ydotool"];
  };
}
