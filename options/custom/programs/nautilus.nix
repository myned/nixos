{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.nautilus;
in {
  options.custom.programs.nautilus = {
    enable = mkOption {default = false;};
    git = mkOption {default = false;};
    index = mkOption {default = true;};
    service = mkOption {default = false;};
    terminal = mkOption {default = "kitty";};
  };

  config = mkIf cfg.enable {
    # TODO: Use module when completed
    # https://github.com/NixOS/nixpkgs/pull/319535
    environment.systemPackages = with pkgs; [nautilus];

    services = {
      gvfs.enable = true; # Trash dependency

      gnome =
        {
          sushi.enable = true; # Quick preview with spacebar
        }
        // optionalAttrs (versionAtLeast version "24.11") {
          # File indexing
          localsearch.enable = cfg.index;
          tinysparql.enable = cfg.index;
        };
    };

    # Alternative fix to services.gnome.core-utilities.enable
    # https://github.com/NixOS/nixpkgs/pull/240780
    #?? echo $NAUTILUS_4_EXTENSION_DIR
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = cfg.terminal;
    };

    home-manager.users.${config.custom.username} = {
      # HACK: Partially fix startup delay with background service until module is available
      systemd.user.services = let
        nautilus = "${pkgs.nautilus}/bin/nautilus";
        turtle_service = "${pkgs.turtle}/bin/turtle_service";
      in {
        nautilus = mkIf cfg.service {
          Unit.Description = "GNOME Files Background Service";
          Install.WantedBy = ["graphical-session.target"];

          Service = {
            BusName = "org.gnome.Nautilus";
            ExecStart = "${nautilus} --gapplication-service";
            ExecStop = "${nautilus} --quit";
            Restart = "always"; #!! Benign exceptions cause nautilus to exit
            Type = "dbus";
          };
        };

        # TODO: Check for module
        # BUG: Benign AttributeError when scanning on nautilus launch
        # Git integration dependency
        turtle = mkIf cfg.git {
          Unit.Description = "Turtle Background Service";
          Install.WantedBy = ["graphical-session.target"];

          Service = {
            BusName = "de.philippun1.turtle";
            ExecStart = turtle_service;
            Restart = "always";
            Type = "dbus";
          };
        };
      };
    };
  };
}
