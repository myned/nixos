{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.git;
in {
  options.custom.programs.git = {
    enable = mkEnableOption "git";
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://git-scm.com
        # https://wiki.nixos.org/wiki/Git
        # https://wiki.archlinux.org/title/Git
        programs.git = {
          enable = true;

          # BUG: GitHub Desktop tries to enable if this is not in gitconfig
          lfs.enable = true; # Large File Storage

          signing = {
            signByDefault = true;
            key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ4hPmotFnneRItm9sU9SrxUTRRLrmB+XnCCywt+lWj6";
            format = "ssh";
          };

          # https://git-scm.com/docs/git-config
          # https://git-scm.com/book/en/v2/
          # https://jvns.ca/blog/2024/02/16/popular-git-config-options/
          settings = {
            # https://git-scm.com/docs/git-config#Documentation/git-config.txt-alias
            #?? git <alias>
            alias = {
              graph = "log --graph --oneline --decorate"; # https://wiki.archlinux.org/title/Git#Visual_representation
            };

            diff = {
              algorithm = "histogram"; # https://git-scm.com/docs/git-config#Documentation/git-config.txt-codediffalgorithmcode
              colorMoved = true; # https://git-scm.com/docs/git-config#Documentation/git-config.txt-codediffcolorMovedcode
            };

            fetch.prune = true; # https://git-scm.com/docs/git-config#Documentation/git-config.txt-fetchprune
            format.signOff = true; # https://git-scm.com/docs/git-config#Documentation/git-config.txt-formatsignOff
            help.autoCorrect = "prompt"; # https://git-scm.com/docs/git-config#Documentation/git-config.txt-helpautoCorrect
            init.defaultBranch = "master"; # https://git-scm.com/docs/git-config#Documentation/git-config.txt-codeinitdefaultBranchcode
            merge.conflictStyle = "zdiff3"; # https://git-scm.com/docs/git-config#Documentation/git-config.txt-mergeconflictStyle
            pull.rebase = true; # https://git-scm.com/docs/git-config#Documentation/git-config.txt-pullrebase
            push.autoSetupRemote = true; # https://git-scm.com/docs/git-config#Documentation/git-config.txt-pushautoSetupRemote

            # https://git-scm.com/docs/git-rebase
            rebase = {
              autoSquash = true; # https://git-scm.com/docs/git-config#Documentation/git-config.txt-rebaseautoSquash
              autoStash = true; # https://git-scm.com/docs/git-config#Documentation/git-config.txt-rebaseautoStash
            };

            rerere.enabled = true; # https://git-scm.com/docs/git-config#Documentation/git-config.txt-rerereenabled
            submodule.recurse = true; # https://git-scm.com/docs/git-config#Documentation/git-config.txt-submodulerecurse
            transfer.fsckObjects = true; # https://git-scm.com/docs/git-config#Documentation/git-config.txt-transferfsckObjects

            user = {
              name = config.custom.realname;
              email = "dev@${config.custom.domain}";
            };
          };
        };
      }
    ];
  };
}
