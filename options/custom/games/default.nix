{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.games;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.games = {
    enable = mkEnableOption "games";

    bottlesDir = mkOption {
      default = "${hm.home.homeDirectory}/.bottles";
      description = "Path to Bottles' prefix directory";
      example = "Games/Bottles";
      type = types.path;
    };

    # TODO: Revisit when per-game prefixes are supported
    # https://github.com/itchio/itch/issues/3085
    # https://github.com/itchio/butler/issues/273
    itchDir = mkOption {
      default = "${hm.home.homeDirectory}/.itch";
      description = "Path to itch's prefix directory";
      example = "Games/Itch";
      type = types.path;
    };

    lutrisDir = mkOption {
      default = "${hm.home.homeDirectory}/.lutris";
      description = "Path to Lutris's prefix directory";
      example = "Games/Lutris";
      type = types.path;
    };

    heroicDir = mkOption {
      default = "${hm.home.homeDirectory}/.heroic";
      description = "Path to Heroic's prefix directory";
      example = "Games/Heroic";
      type = types.path;
    };

    retroDir = mkOption {
      default = "${config.custom.syncDir}/game/retrodeck/saves";
      description = "Path to RetroDeck's saves directory";
      example = "Games/RetroDeck/saves";
      type = types.path;
    };

    steamDir = mkOption {
      default = "${hm.home.homeDirectory}/.local/share/Steam/steamapps/compatdata";
      description = "Path to Steam's prefix directory";
      example = "Games/Steam/steamapps/compatdata";
      type = types.path;
    };

    steamID64 = mkOption {
      default = "76561198122574159";
      description = "String of the ID64 number associated with a Steam account";
      example = "76565672846371223";
      type = types.str;
    };
  };
}
