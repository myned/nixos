{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.clipsync;

  clipnotify = getExe pkgs.clipnotify;
  wl-copy = getExe' pkgs.wl-clipboard "wl-copy";
  wl-paste = getExe' pkgs.wl-clipboard "wl-paste";
  xclip = getExe pkgs.xclip;
in {
  options.custom.services.clipsync = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://github.com/cdown/clipnotify
    systemd.user.services.clipsync = {
      enable = true;
      wantedBy = ["graphical-session.target"];

      unitConfig = {
        Description = "Sync clipboard between Wayland and X11";

        After =
          ["graphical-session.target"]
          ++ optionals config.custom.services.xwayland-satellite.enable ["xwayland-satellite.service"];
      };

      serviceConfig = {
        Type = "simple";

        ExecStart = pkgs.writeShellScript "clipsync" ''
          # Push Wayland clipboard to X11
          ${wl-paste} --watch ${xclip} -selection clipboard &

          # When X11 clipboard changes
          while ${clipnotify}; do
            # Push X11 clipboard to Wayland if not a duplicate
            if [[ "$(${wl-paste})" != "$(${xclip} -selection clipboard -out)" ]]; then
              ${xclip} -selection clipboard -out | ${wl-copy}
            fi
          done
        '';
      };
    };
  };
}
