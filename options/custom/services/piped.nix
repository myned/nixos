{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  curl = "${pkgs.curl}/bin/curl";
  docker = "${pkgs.docker}/bin/docker";
  parallel = "${pkgs.parallel}/bin/parallel";

  cfg = config.custom.services.piped;
in
{
  options.custom.services.piped.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Systemd/timers

    # Manually fetch channels in background
    # TODO: Remove when fixed upstream
    # https://github.com/TeamPiped/Piped/issues/1130
    systemd = {
      services."fetch-channels" = {
        script = ''
          ${docker} compose --file /docker/piped/docker-compose.yml exec postgres \
            psql \
              --username piped \
              --dbname piped \
              --tuples-only \
              --no-align \
              --quiet \
              --command 'SELECT DISTINCT(channel) FROM users_subscribed' | \
          ${parallel} ${curl} --silent --output /dev/null 'https://pipedapi.bjork.tech/channel/{}'
        '';
      };

      timers."fetch-channels" = {
        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnBootSec = "1h";
          OnUnitActiveSec = "1h";
        };
      };
    };
  };
}
