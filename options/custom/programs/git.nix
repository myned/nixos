{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.git;
in {
  options.custom.programs.git.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/Git
    # https://git-scm.com
    programs.git = {
      enable = true;
      userName = "Myned";
      userEmail = "dev@bjork.tech";

      # BUG: GitHub Desktop tries to enable if this is not in gitconfig
      lfs.enable = true; # Enable Large File Storage

      signing = {
        signByDefault = true;
        key = "C7224454F7881A34";
      };

      extraConfig = {
        init.defaultBranch = "master";
        push.autoSetupRemote = true;
        pull.ff = "only";
        url."git@github.com:".insteadOf = [
          "gh:"
          "github:"
        ];
      };
    };
  };
}
