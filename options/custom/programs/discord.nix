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
    home.file.".config/BetterDiscord".source =
      config.home-manager.users.${config.custom.username}.lib.file.mkOutOfStoreSymlink
      "/home/${config.custom.username}/SYNC/common/config/discord/BetterDiscord";
  };
}
