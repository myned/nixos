{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.git;
in {
  options.custom.programs.git = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://git-scm.com
        # https://wiki.nixos.org/wiki/Git
        # https://wiki.archlinux.org/title/Git
        programs.git = {
          enable = true;
          userName = "Myned";
          userEmail = "dev@${config.custom.domain}";

          # BUG: GitHub Desktop tries to enable if this is not in gitconfig
          lfs.enable = true; # Large File Storage

          signing =
            {
              signByDefault = true;
              key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ4hPmotFnneRItm9sU9SrxUTRRLrmB+XnCCywt+lWj6";
            }
            // optionalAttrs (versionAtLeast version "25.05") {
              format = "ssh";
            };

          # https://git-scm.com/docs/git-config
          # https://git-scm.com/book/en/v2/
          # https://jvns.ca/blog/2024/02/16/popular-git-config-options/
          extraConfig = {
            # https://git-scm.com/docs/git-config#Documentation/git-config.txt-alias
            #?? git ALIAS
            alias = {
              # https://wiki.archlinux.org/title/Git#Visual_representation
              graph = "log --graph --oneline --decorate";
            };

            diff = {
              # https://git-scm.com/docs/git-config#Documentation/git-config.txt-codediffalgorithmcode
              algorithm = "histogram";

              # https://git-scm.com/docs/git-config#Documentation/git-config.txt-codediffcolorMovedcode
              colorMoved = true;
            };

            # https://git-scm.com/docs/git-config#Documentation/git-config.txt-fetchprune
            fetch.prune = true;

            # https://git-scm.com/docs/git-config#Documentation/git-config.txt-formatsignOff
            #?? Signed-off-by: USERNAME <EMAIL>
            format.signOff = true;

            # https://git-scm.com/docs/git-config#Documentation/git-config.txt-helpautoCorrect
            help.autoCorrect = "prompt";

            # https://git-scm.com/docs/git-config#Documentation/git-config.txt-codeinitdefaultBranchcode
            init.defaultBranch = "master"; # owo

            # https://git-scm.com/docs/git-config#Documentation/git-config.txt-mergeconflictStyle
            merge.conflictStyle = "zdiff3";

            # https://git-scm.com/docs/git-config#Documentation/git-config.txt-pullrebase
            pull.rebase = true;

            # https://git-scm.com/docs/git-config#Documentation/git-config.txt-pushautoSetupRemote
            push.autoSetupRemote = true;

            # https://git-scm.com/docs/git-rebase
            rebase = {
              # https://git-scm.com/docs/git-config#Documentation/git-config.txt-rebaseautoSquash
              autoSquash = true;

              # https://git-scm.com/docs/git-config#Documentation/git-config.txt-rebaseautoStash
              autoStash = true;
            };

            # https://git-scm.com/docs/git-config#Documentation/git-config.txt-rerereenabled
            rerere.enabled = true; # reuse recovered resolution

            # https://git-scm.com/docs/git-config#Documentation/git-config.txt-submodulerecurse
            submodule.recurse = true;

            # https://git-scm.com/docs/git-config#Documentation/git-config.txt-transferfsckObjects
            transfer.fsckObjects = true;
          };
        };
      }
    ];
  };
}
