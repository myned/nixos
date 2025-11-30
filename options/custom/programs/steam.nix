{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.steam;
in {
  # https://wiki.nixos.org/wiki/Steam
  # https://store.steampowered.com
  options.custom.programs.steam = {
    enable = mkEnableOption "steam";

    extest = mkOption {
      default = false;
      description = "Whether to enable Xwayland input translation hack";
      example = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      extest.enable = cfg.extest;
      protontricks.enable = true;
      localNetworkGameTransfers.openFirewall = true; # 27040/tcp 27036/udp
      remotePlay.openFirewall = true; # 27036/tcp/udp 27031-27035/udp
      extraCompatPackages = [pkgs.proton-ge-bin];

      gamescopeSession = {
        enable = true;

        env = {
          PROTON_ENABLE_WAYLAND = "0"; # Gamescope is X11-only
        };
      };

      # HACK: Work around black main window with xwayland-satellite
      # https://github.com/ValveSoftware/steam-for-linux/issues/10543 et al.
      package = (
        pkgs.steam.override {
          extraArgs = "-system-composer";

          extraEnv = {
            GDK_SCALE = toString config.custom.scale; # Fractional scaling

            # HACK: Force XInput controller so only Steam Input is used, requires Proton GE
            # https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/issues/4168
            # https://github.com/GloriousEggroll/proton-ge-custom/wiki/Changelog#ge-proton10-7-hotfix
            PROTON_DISABLE_HIDRAW = "1";
            PROTON_PREFER_SDL = "1";

            # https://github.com/GloriousEggroll/proton-ge-custom?tab=readme-ov-file#enabling-native-wayland
            PROTON_ENABLE_WAYLAND = "1";
          };
        }
      );
    };

    environment.systemPackages = with pkgs; [
      adwsteamgtk # https://github.com/Foldex/AdwSteamGtk
      sgdboop # https://github.com/SteamGridDB/SGDBoop
      steam-rom-manager # https://github.com/SteamGridDB/steam-rom-manager

      # https://github.com/sonic2kk/steamtinkerlaunch
      # TODO: Remove when v14 released on nixpkgs
      # https://github.com/sonic2kk/steamtinkerlaunch/issues/992
      # Build from latest commit
      #// (steamtinkerlaunch.overrideAttrs {src = inputs.steamtinkerlaunch;})
      #// p7zip # steamtinkerlaunch (Special K)
    ];
  };
}
