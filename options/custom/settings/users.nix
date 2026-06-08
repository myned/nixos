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
          extraGroups = ["input" "video" "wheel"];
          hashedPasswordFile = config.age.secrets."${config.custom.hostname}/users/${config.custom.username}.pass".path;
          uid = 1000;
        };
      };
    };

    home-manager.users = {
      # TODO: Only allow a subset of home-manager modules for root user
      #// root.home.homeDirectory = config.users.users.root.home;

      ${config.custom.username}.home.homeDirectory = config.users.users.${config.custom.username}.home;
    };
  };
}
