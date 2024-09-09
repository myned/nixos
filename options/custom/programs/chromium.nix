{ config, lib, ... }:

with lib;

let
  cfg = config.custom.programs.chromium;
in
{
  options.custom.programs.chromium.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Chromium
    # https://www.chromium.org/chromium-projects
    programs.chromium = {
      enable = true;

      commandLineArgs = [
        "--enable-features=OverlayScrollbar,ChromeRefresh2023,TabGroupsSave,TouchpadOverscrollHistoryNavigation"
      ];

      extensions = [
        #"ajopnjidmegmdimjlfnijceegpefgped" # BetterTTV
        #"nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        #"enamippconapkdmgfgjchkhakpfinmaj" # DeArrow
        #"fnaicdffflnofjppbagibeoednhnbjhg" # floccus
        #"bnomihfieiccainjcjblhegjgglakjdd" # Improve YouTube
        #"mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
        #"clngdbkpkpeebahjckkjfobafhncgmne" # Stylus
        #"kfidecgcdjjfpeckbblhmfkhmlgecoff" # Svelte DevTools
        #"nplimhmoanghlebhdiboeellhgmgommi" # Tab Groups Extension
        "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
      ];
    };
  };
}
