{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.games.baba-is-you;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.games.baba-is-you = {
    enable = mkEnableOption "baba-is-you";
  };

  config = mkIf cfg.enable {
    # https://www.protondb.com/app/736260
    # https://www.pcgamingwiki.com/wiki/Baba_Is_You
    systemd.user.tmpfiles.rules = [
      "L+ ${hm.xdg.dataHome}/Baba_Is_You - - - - ${config.custom.syncDir}/game/saves/baba-is-you/${config.custom.username}/Baba_Is_You"
    ];
  };
}
