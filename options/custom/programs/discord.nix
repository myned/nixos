{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.discord;
in {
  options.custom.programs.discord.enable = mkOption {default = false;};

  config.home-manager.users.myned = mkIf cfg.enable {
    xdg.configFile."BetterDiscord" = {
      force = true;
      source = config.home-manager.users.${config.custom.username}.lib.file.mkOutOfStoreSymlink "${config.custom.sync}/common/config/discord/BetterDiscord";
    };
  };
}
