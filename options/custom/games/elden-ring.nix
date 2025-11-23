{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.games.elden-ring;
in {
  options.custom.games.elden-ring = {
    enable = mkEnableOption "elden-ring";
  };

  config = mkIf cfg.enable {
    # https://www.protondb.com/app/1245620
    # https://www.pcgamingwiki.com/wiki/Elden_Ring
    environment.systemPackages = with pkgs; [
      er-patcher # ER fixes
    ];

    systemd.user.tmpfiles.rules = [
      "L+ ${config.custom.games.steamDir}/1245620/pfx/drive_c/users/steamuser/AppData/Roaming/EldenRing/${config.custom.games.steamID64} - - - - ${config.custom.sync}/game/saves/elden-ring/${config.custom.username}/${config.custom.games.steamID64}"
    ];
  };
}
