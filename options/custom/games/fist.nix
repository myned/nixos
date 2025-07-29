{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.games.fist;
in {
  options.custom.games.fist = {
    enable = mkEnableOption "fist";
  };

  config = mkIf cfg.enable {
    # https://www.protondb.com/app/1330470
    # https://www.pcgamingwiki.com/wiki/F.I.S.T.:_Forged_in_Shadow_Torch
    systemd.user.tmpfiles.rules = [
      "L+ ${config.custom.games.heroicDir}/F.I.S.T. Forged In Shadow Torch/drive_c/users/${config.custom.username}/AppData/Local/ZingangGame/Saved/Config/SaveGames - - - - ${config.custom.sync}/game/saves/fist/${config.custom.username}/SaveGames"
    ];
  };
}
