{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.desktops.niri;
in {
  options.custom.desktops.niri = {
    enable = mkOption {default = false;};
    polkit = mkOption {default = false;};
    xwayland = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    custom.desktops.niri = mkIf config.custom.full {
      binds.enable = true;
      input.enable = true;
      layout.enable = true;
      misc.enable = true;
      rules.enable = true;
    };

    # https://github.com/YaLTeR/niri
    # https://github.com/sodiboo/niri-flake
    # https://github.com/sodiboo/niri-flake/blob/main/docs.md
    programs.niri = {
      enable = true;
      package = pkgs.niri; # nixpkgs
    };

    nixpkgs.overlays = [inputs.niri.overlays.niri];

    #!! Disabled bundled KDE polkit agent
    # https://github.com/sodiboo/niri-flake?tab=readme-ov-file#additional-notes
    systemd.user.services.niri-flake-polkit.enable = cfg.polkit;

    # Enable rootless Xwayland
    custom.services.xwayland-satellite.enable = cfg.xwayland;

    home-manager.users.${config.custom.username} = {
      programs.niri.package = config.programs.niri.package;
    };
  };
}
