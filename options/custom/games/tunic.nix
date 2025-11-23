{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.games.tunic;
in {
  options.custom.games.tunic = {
    enable = mkEnableOption "tunic";
  };

  config = mkIf cfg.enable {
    # https://www.protondb.com/app/553420
    # https://www.pcgamingwiki.com/wiki/Tunic
    systemd.user.tmpfiles.rules = [
      "L+ '${config.custom.games.itchDir}/tunic/drive_c/users/steamuser/AppData/LocalLow/Andrew Shouldice/Secret Legend/SAVES' - - - - ${config.custom.syncDir}/game/saves/tunic/${config.custom.username}/SAVES"
    ];
  };
}
