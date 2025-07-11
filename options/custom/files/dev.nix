{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.files.dev;
in {
  options.custom.files.dev.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # .keep empty file needed to create empty directory
    # https://github.com/nix-community/home-manager/issues/2104
    home.file.".dev/.keep".text = ""; # Development folder
  };
}
