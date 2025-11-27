{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.pipewire;
in {
  options.custom.services.pipewire = {
    enable = mkOption {default = false;};
    enableAlsa = mkOption {default = true;};
    enableJack = mkOption {default = true;};
    enablePulseaudio = mkOption {default = true;};
    systemWide = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    #!! Realtime priority may cause desync
    #// security.rtkit.enable = true;

    services = {
      #!! Conflicts with pipewire
      pulseaudio.enable = false;

      # https://wiki.nixos.org/wiki/PipeWire
      # https://gitlab.freedesktop.org/pipewire/pipewire
      pipewire = {
        enable = true;
        systemWide = cfg.systemWide;
        jack.enable = cfg.enableJack;
        pulse.enable = cfg.enablePulseaudio;

        alsa = mkIf cfg.enableAlsa {
          enable = true;
          support32Bit = true;
        };

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

    #?? alsamixer
    environment.systemPackages = optionals cfg.enableAlsa [pkgs.alsa-utils];
  };
}
