{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.games.remnant;
in {
  options.custom.games.remnant = {
    enable = mkEnableOption "remnant";
  };

  config = mkIf cfg.enable {
    # https://www.protondb.com/app/617290
    # https://www.pcgamingwiki.com/wiki/Remnant:_From_the_Ashes
    systemd.user.tmpfiles.rules = [
      "L+ ${config.custom.games.steamDir}/617290/pfx/drive_c/users/steamuser/AppData/Local/Remnant/Saved/SaveGames - - - - ${config.custom.syncDir}/game/saves/remnant/${config.custom.username}/SaveGames"
    ];
  };
}
