{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.tmux;
in
{
  options.custom.programs.tmux.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Tmux
    # https://github.com/tmux/tmux
    programs.tmux = {
      enable = true;
      shortcut = "t";
      terminal = "tmux-256color";
    };
  };
}
