{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.fish;
in {
  options.custom.programs.fish.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Fish
    # https://github.com/fish-shell/fish-shell
    programs.fish = {
      enable = true;

      promptInit = ''
        # Disable greeting
        set -g fish_greeting

        # Prompt
        function fish_prompt --description 'Write out the prompt'
          set -l last_status $status
          set -l normal (set_color normal)
          set -l status_color (set_color brgreen)
          set -l cwd_color (set_color $fish_color_cwd)
          set -l vcs_color (set_color brpurple)
          set -l prompt_status ""

          # Since we display the prompt on a new line allow the directory names to be longer.
          set -q fish_prompt_pwd_dir_length
          or set -lx fish_prompt_pwd_dir_length 0

          # Color the prompt differently when we're root
          set -l suffix '❯'
          if functions -q fish_is_root_user; and fish_is_root_user
              if set -q fish_color_cwd_root
                  set cwd_color (set_color $fish_color_cwd_root)
              end
              set suffix '#'
          end

          # Color the prompt in red on error
          if test $last_status -ne 0
              set status_color (set_color $fish_color_error)
              set prompt_status $status_color "[" $last_status "]" $normal
          end

          echo -s (prompt_login) ' ' $cwd_color (prompt_pwd) $vcs_color (fish_vcs_prompt) $normal ' ' $prompt_status
          echo -n -s $status_color $suffix ' ' $normal
        end
      '';
    };

    home-manager.users = {
      # Inherit root abbreviations from user
      root.programs.fish = {
        enable = true;
        shellAbbrs = config.home-manager.users.${config.custom.username}.programs.fish.shellAbbrs;
      };

      ${config.custom.username}.programs.fish = let
        any = expansion: {
          inherit expansion;
          position = "anywhere";
        };
      in {
        enable = true;

        shellAbbrs = {
          # Expand abbreviations anywhere in the shell
          #?? sudo ABBREVIATION
          "/e" = any "/etc";
          "/en" = any "/etc/nixos";
          "/h" = any "~";
          "/hd" = any "~/.dev";
          "/n" = any "/nix";
          "/nv" = any "/nix/var";
          "/nvn" = any "/nix/var/nix";
          "/nvnp" = any "/nix/var/nix/profiles";
          "/nvnps" = any "/nix/var/nix/profiles/system";
          "/r" = any "/run";
          "/rc" = any "/run/current-system";

          reboot = any "systemctl reboot";
          restart = any "systemctl reboot";
          poweroff = any "systemctl poweroff";
          shutdown = any "systemctl poweroff";

          backup = any "borgmatic -v 1 create --progress --stats";
          extract = any "borgmatic -v 1 extract --progress";
          init = any "borgmatic init -e repokey-blake2";
          key = any "borgmatic key export";
          list = any "borgmatic -v 1 list";
          restore = any "borgmatic -v 1 restore";

          rsync = any "rsync --info=progress2";

          jc = any "journalctl";
          jcs = any "journalctl --system";
          jcse = any "journalctl --system --pager-end";
          jcseu = any "journalctl --system --pager-end --unit";
          jcsf = any "journalctl --system --follow";
          jcsfu = any "journalctl --system --follow --unit";
          jcsi = any "journalctl --system --identifier";
          jcst = any "journalctl --system --target";
          jcsu = any "journalctl --system --unit";
          jcu = any "journalctl --user";
          jcue = any "journalctl --user --pager-end";
          jcueu = any "journalctl --user --pager-end --unit";
          jcuf = any "journalctl --user --follow";
          jcufu = any "journalctl --user --follow --unit";
          jcui = any "journalctl --user --identifier";
          jcut = any "journalctl --user --target";
          jcuu = any "journalctl --user --unit";

          sc = any "systemctl";
          scp = any "systemctl poweroff";
          scr = any "systemctl reboot";
          scs = any "systemctl --system";
          scsd = any "systemctl --system disable";
          scsdn = any "systemctl --system disable --now";
          scse = any "systemctl --system reenable";
          scsen = any "systemctl --system reenable --now";
          scsh = any "systemctl --system show";
          scsl = any "systemctl --system list-unit-files";
          scsm = any "systemctl --system mask";
          scsr = any "systemctl --system restart";
          scsrr = any "systemctl --system reload-or-restart";
          scss = any "systemctl --system status";
          scst = any "systemctl --system stop";
          scsu = any "systemctl --system unmask";
          scu = any "systemctl --user";
          scud = any "systemctl --user disable";
          scudn = any "systemctl --user disable --now";
          scue = any "systemctl --user reenable";
          scuen = any "systemctl --user reenable --now";
          scuh = any "systemctl --user show";
          scul = any "systemctl --user list-unit-files";
          scum = any "systemctl --user mask";
          scur = any "systemctl --user restart";
          scurr = any "systemctl --user reload-or-restart";
          scus = any "systemctl --user status";
          scut = any "systemctl --user stop";
          scuu = any "systemctl --user unmask";

          d = any "docker";
          dc = any "docker compose";
          dcd = any "docker compose down";
          dce = any "docker compose exec";
          dcl = any "docker compose logs";
          dcp = any "docker compose pull";
          dcu = any "docker compose up";
          dcuf = any "docker compose up --force-recreate";
          de = any "docker exec";
          dei = any "docker exec --interactive";
          deit = any "docker exec --interactive --tty";
          det = any "docker exec --tty";
          di = any "docker images";
          dk = any "docker kill";
          dn = any "docker network";
          dnl = any "docker network ls";
          dp = any "docker pull";
          dps = any "docker ps";
          dpsa = any "docker ps --all --size";
          dr = any "docker rm";
          ds = any "docker system";
          dsp = any "docker system prune";
          dspav = any "docker system prune --all --volumes";

          c = "clear";
          e = "exit";
          m = "mosh";
          s = "ssh";

          ip = "tailscale ip --4";

          n = "nixos";
          nb = "nixos build";
          nbb = "nixos build boot";
          nbs = "nixos build switch";
          nbt = "nixos build test";
          nd = "nixos diff";
          ng = "nixos generate";
          nl = "nixos list";
          nr = "nixos repl";

          g = "git";
          gb = "git bisect";
          gbb = "git bisect bad";
          gbg = "git bisect good";
          gc = "git clone";
          gs = "git status";

          ta = "tmux attach";
          td = "tmux detach";
          tk = "tmux kill-session";
          tl = "tmux list-sessions";

          k = "kitten";
          ks = "kitten ssh";
        };

        interactiveShellInit = ''
          # Default is brblack (bright0)
          set -g fish_color_autosuggestion brgreen

          function exit -d 'Always exit successfully when interactive'
            builtin exit 0
          end

          # TODO: Pass flags properly
          # TODO: Convert to bash
          function run -d 'Run packages via nixpkg flakes'
            for i in (seq (count $argv))
              if ! string match -r '^-' -- $argv[$i]
                set argv[$i] (string replace -r ^ nixpkgs# $argv[$i])
              end
            end
            nix run $argv
          end

          function shell -d 'Open packages in new shell via nixpkg flakes'
            for i in (seq (count $argv))
              if ! string match -r '^-' -- $argv[$i]
                set argv[$i] (string replace -r ^ nixpkgs# $argv[$i])
              end
            end
            nix shell $argv
          end

          function activate -d 'Activate Python venv'
            source .venv/bin/activate.fish
          end

          function arknights -d 'Launch Arknights'
            waydroid app launch com.YoStarEN.Arknights
          end
        '';
      };
    };
  };
}
