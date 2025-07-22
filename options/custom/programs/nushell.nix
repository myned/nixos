{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.nushell;
in {
  options.custom.programs.nushell = {
    enable = mkEnableOption "nushell";
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # TODO: Create config
      # https://github.com/nushell/nushell
      programs.nushell = {
        enable = true;
      };

      # https://nix-community.github.io/stylix/options/modules/nushell.html
      stylix.targets.nushell.enable = true;
    };
  };
}
