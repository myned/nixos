{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.ssh;
in {
  options.custom.programs.ssh.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.users.${config.custom.username} = {
      programs.ssh = {
        enable = true;

        # https://ghostty.org/docs/help/terminfo#configure-ssh-to-fall-back-to-a-known-terminfo-entry
        extraConfig = ''
          Host *
            SetEnv TERM=xterm-256color
        '';
      };

      # Work around FHS permissions
      # https://github.com/nix-community/home-manager/issues/322#issuecomment-1856128020
      home.file.".ssh/config" = {
        target = ".ssh/config_source";
        onChange = "cat ~/.ssh/config_source > ~/.ssh/config && chmod 400 ~/.ssh/config";
      };
    };
  };
}
