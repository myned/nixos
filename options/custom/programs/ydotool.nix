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
    custom.settings.users.${config.custom.username}.groups = ["ydotool"];

    # https://github.com/ReimuNotMoe/ydotool
    programs.ydotool.enable = true;
  };
}
