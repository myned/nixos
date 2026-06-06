{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.scrutiny;
in {
  options.custom.services.scrutiny = {
    enable = mkEnableOption "scrutiny";

    server = mkOption {
      default = "myore";
      description = "Hostname of the machine to send metrics";
      example = "localhost";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # https://github.com/AnalogJ/scrutiny
    services.scrutiny = {
      enable = cfg.server == config.custom.hostname;
      influxdb.enable = cfg.server == config.custom.hostname;

      collector = {
        enable = !config.custom.vm;

        # https://github.com/AnalogJ/scrutiny/blob/master/example.collector.yaml
        settings = {
          api.endpoint = with config.services.scrutiny.settings.web.listen; "http://${cfg.server}:${toString port}${basepath}";
          host.id = config.custom.hostname;
        };
      };

      # https://github.com/AnalogJ/scrutiny/blob/master/example.scrutiny.yaml
      settings = {
        #?? curl -X POST https://scrutiny.admin.<domain>/api/health/notify
        notify.urls = ["ntfy://notify.${config.custom.domain}/status"];

        web.listen = {
          host = config.custom.services.tailscale.ipv4;
          port = 8282;
        };
      };
    };

    # Wait for tailscale to connect before running
    systemd.services.scrutiny-collector = mkIf config.services.scrutiny.collector.enable {
      after = optionals config.custom.services.tailscale.enable ["tailscaled.service"];
    };
  };
}
