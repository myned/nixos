{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.discord;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.discord.enable = mkOption {default = false;};

  config.home-manager.users.myned = mkIf cfg.enable {
    xdg.configFile."BetterDiscord" = {
      force = true;
      source = hm.lib.file.mkOutOfStoreSymlink "${config.custom.sync}/common/config/discord/BetterDiscord";
    };
  };
}
