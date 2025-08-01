{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.wallpaper;

  wallpaper = getExe (pkgs.writeShellApplication {
    name = "wallpaper.sh";
    text = readFile ./wallpaper.sh;

    runtimeInputs = with pkgs; [
      coreutils
      fd
      imagemagick
      libnotify
      rsync
      swww
      tailscale
    ];
  });
in {
  options.custom.services.wallpaper = {
    enable = mkEnableOption "wallpaper";

    directory = mkOption {
      default = "${config.custom.sync}/owo/unsorted";
      type = types.path;
    };
  };

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      # https://github.com/LGFae/swww
      services.swww.enable = true;

      systemd.user.services.wallpaper = {
        Unit = {
          Description = "Periodically change wallpaper";
          Requires = ["swww.service"];
          After = ["graphical-session.target" "swww.service"];
        };

        Service = {
          Type = "simple";
          ExecStart = "${wallpaper} ${cfg.directory}";
          Restart = "always";
        };

        Install = {
          WantedBy = ["default.target"];
        };
      };
    };
  };
}
