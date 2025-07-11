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
      linger = mkOption {default = false;};
      packages = mkOption {default = [];};
    };
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
      };
    in {
      "${config.custom.profile}/users/${config.custom.username}.pass" = secret "${config.custom.profile}/users/${config.custom.username}.pass";
      "${config.custom.profile}/users/root.pass" = secret "${config.custom.profile}/users/root.pass";
    };

    users = {
      defaultUserShell = cfg.shell;
      mutableUsers = false; # !! Immutable users

      users = {
        #!! secrets/PROFILE/users/USERNAME.pass hashedPasswordFile is required

        root.hashedPasswordFile = config.age.secrets."${config.custom.profile}/users/root.pass".path;

        ${config.custom.username} = {
          isNormalUser = true;
          extraGroups = ["wheel"] ++ cfg.${config.custom.username}.groups;
          hashedPasswordFile = config.age.secrets."${config.custom.profile}/users/${config.custom.username}.pass".path;
          linger = cfg.${config.custom.username}.linger;
          packages = cfg.${config.custom.username}.packages;
          uid = 1000;
        };
      };
    };
  };
}
