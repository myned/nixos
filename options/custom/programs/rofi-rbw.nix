{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.rofi-rbw;
in {
  options.custom.programs.rofi-rbw.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/fdw/rofi-rbw
    #!! Options not available, files written directly
    # https://github.com/fdw/rofi-rbw?tab=readme-ov-file#configuration
    # TODO: Enable input emulation when merged (uinput.enable?)
    # https://github.com/NixOS/nixpkgs/pull/303745
    xdg.configFile."rofi-rbw.rc".text = ''
      action=copy
    '';
  };
}
