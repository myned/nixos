{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.games.cemu;
in {
  options.custom.games.cemu = {
    enable = mkEnableOption "cemu";
  };

  config = mkIf cfg.enable {
    # https://retrodeck.readthedocs.io/en/latest/wiki_emulator_guides/cemu/cemu-guide/
    systemd.user.tmpfiles.rules = [
      "L+ ${config.custom.games.retroDir}/wiiu/cemu - - - - ${config.custom.sync}/game/saves/cemu/${config.custom.username}/cemu"
    ];
  };
}
