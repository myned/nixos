{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.mpd;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.services.mpd = {
    enable = mkEnableOption "mpd";
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf (!config.custom.services.tailscale.enable) {
      allowedUDPPorts = [hm.services.mpd.network.port];
    };

    home-manager.sharedModules = [
      {
        # https://wiki.nixos.org/wiki/MPD
        # https://github.com/MusicPlayerDaemon/MPD
        services.mpd = {
          enable = true;

          network = {
            #// port = 6600;

            listenAddress = with config.custom.services.tailscale;
              if enable
              then ip
              else null;
          };
        };
      }
    ];
  };
}
