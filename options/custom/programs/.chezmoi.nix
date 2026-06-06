{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.chezmoi;
in {
  options.custom.programs.chezmoi = {
    enable = mkEnableOption "chezmoi";
  };

  config = mkIf cfg.enable {
    #!! Imperative configuration
    # https://www.chezmoi.io/
    # https://github.com/twpayne/chezmoi
    environment.systemPackages = [pkgs.chezmoi];

    home-manager.sharedModules = [
      {
        programs.fish.shellAbbrs =
          # Set all cursor positions to %
          mapAttrs (name: value: {
            expansion = value;
            setCursor = true;
          }) {
            ch = "chezmoi";
            cha = "chezmoi add";
            chaf = "chezmoi add --follow";
            chc = "chezmoi cat";
            chcd = "chezmoi cd";
            chd = "chezmoi diff";
            chdoc = "chezmoi doctor";
            che = "chezmoi edit";
            chew = "chezmoi edit --watch";
            chey = "chezmoi edit --apply";
            chg = "chezmoi git";
            chi = "chezmoi init";
            chia = "chezmoi init --apply";
            chiad = "chezmoi init --apply https://git.${config.custom.domain}/myned/dotfiles";
            chm = "chezmoi merge";
            chma = "chezmoi merge-all";
            chs = "chezmoi status";
            cht = "chezmoi chattr --recursive";
            chtn = "chezmoi chattr --recursive noprivate,noreadonly";
            chu = "chezmoi update";
            chx = "chezmoi execute-template";
            chy = "chezmoi apply";
          };
      }
    ];
  };
}
