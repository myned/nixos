{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.sway;
in {
  options.custom.desktops.sway.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    custom.desktops.sway = mkIf config.custom.full {
      binds.enable = true;
      input.enable = true;
      output.enable = true;
      rules.enable = true;
      settings.enable = true;
      swayfx.enable = true;
    };

    # https://wiki.nixos.org/wiki/Sway
    # https://wiki.archlinux.org/title/Sway
    # https://github.com/swaywm/sway
    programs.sway.enable = true;

    home-manager.users.${config.custom.username} = {
      #?? man sway[msg|-ipc]
      wayland.windowManager.sway = {
        enable = true;

        # TODO: Remove when fixed upstream
        # https://github.com/swaywm/sway/pull/7780
        # Disable direct scanout for fullscreen vrr
        # https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.sway.extraOptions
        extraOptions = ["-Dnoscanout"];

        # HACK: Export mapped home-manager variables in lieu of upstream fix
        # https://github.com/nix-community/home-manager/issues/2659
        # https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.sway.extraSessionCommands
        extraSessionCommands = with builtins;
          concatStringsSep "\n" (attrValues
            (
              mapAttrs
              (name: value: "export ${name}=${toString value}")
              config.home-manager.users.${config.custom.username}.home.sessionVariables
            ));

        # Import some necessary variables from systemd
        # https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.sway.systemd.variables
        systemd.variables = ["--all"];

        # Otherwise GTK applications take a while to start
        # https://github.com/swaywm/sway/wiki#gtk-applications-take-20-seconds-to-start
        # https://nix-community.github.io/home-manager/options.xhtml#opt-wayland.windowManager.sway.wrapperFeatures
        wrapperFeatures.gtk = true;
      };
    };
  };
}
