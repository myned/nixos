{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.users;
in {
  options.custom.settings.users = {
    enable = mkOption {default = false;};
    shell = mkOption {default = pkgs.fish;};

    ${config.custom.username} = {
      groups = mkOption {
        default =
          if config.custom.full
          then [
            "input"
            "video"
          ]
          else [];
      };
      linger = mkOption {default = true;};
      packages = mkOption {default = [];};
    };
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.hostname}/users/${config.custom.username}.pass" = secret "${config.custom.hostname}/users/${config.custom.username}.pass";
      "${config.custom.hostname}/users/root.pass" = secret "${config.custom.hostname}/users/root.pass";
    };

    users = {
      defaultUserShell = cfg.shell;
      mutableUsers = false; #!! Immutable users

      users = {
        root.hashedPasswordFile = config.age.secrets."${config.custom.hostname}/users/root.pass".path;

        ${config.custom.username} = {
          isNormalUser = true;
          extraGroups = ["wheel"] ++ cfg.${config.custom.username}.groups;
          hashedPasswordFile = config.age.secrets."${config.custom.hostname}/users/${config.custom.username}.pass".path;
          linger = cfg.${config.custom.username}.linger;
          packages = cfg.${config.custom.username}.packages;
          uid = 1000;
        };
      };
    };

    home-manager.users = {
      root.home.homeDirectory = config.users.users.root.home;
      ${config.custom.username}.home.homeDirectory = config.users.users.${config.custom.username}.home;
    };
  };
}
