{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.pipewire;
in {
  options.custom.services.pipewire.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/PipeWire
    # https://gitlab.freedesktop.org/pipewire/pipewire
    #!! Realtime priority may cause desync
    #// security.rtkit.enable = true;
    hardware.pulseaudio.enable = false;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      # Avoid resampling if possible
      # https://wiki.archlinux.org/title/PipeWire#Changing_the_allowed_sample_rate(s)
      extraConfig.pipewire = {
        "10-sample-rate"."context.properties"."default.clock.allowed-rates" = [
          32000
          44100
          48000
          88200
          96000
          176400
          192000
        ];
      };
    };
  };
}
