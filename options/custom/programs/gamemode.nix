{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.gamemode;
  hm = config.home-manager.users.${config.custom.username};

  gpurun = hm.home.file.".local/bin/gpurun".source;
  mangohud = getExe' hm.programs.mangohud.package "mangohud";
in {
  options.custom.programs.gamemode = {
    enable = mkEnableOption "gamemode";
  };

  config = mkIf cfg.enable {
    # https://github.com/FeralInteractive/gamemode
    programs.gamemode.enable = true;

    home-manager.users.${config.custom.username} = {
      # https://github.com/FeralInteractive/gamemode?tab=readme-ov-file#note-for-hybrid-gpu-users
      home.sessionVariables = {
        GAMEMODERUNEXEC =
          if with config.custom.vms.passthrough; (enable && blacklist)
          then "${gpurun} ${config.custom.settings.hardware.dgpu.driver}"
          else "${mangohud}";
      };
    };
  };
}
