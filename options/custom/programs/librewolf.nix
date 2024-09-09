{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.librewolf;
in
{
  options.custom.programs.librewolf.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://codeberg.org/librewolf
    # TODO: Revisit when extensions can be managed declaratively
    # https://github.com/nix-community/home-manager/issues/2803
    programs.librewolf.enable = true;
  };
}
