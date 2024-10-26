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
    programs.fish.enable = true;

    home-manager.users = {
      # Inherit root configuration from user
      root.programs.fish = with config.home-manager.users.${config.custom.username}.programs.fish; {
        inherit enable interactiveShellInit shellAbbrs;
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

          reboot = "systemctl reboot";
          restart = "systemctl reboot";
          poweroff = "systemctl poweroff";
          shutdown = "systemctl poweroff";

          rsync = "rsync --info progress2";

          a = "adb";
          as = "adb shell";
          asa = "adb shell sh /sdcard/Android/data/com.llamalab.automate/cache/start.sh"; # Automate

          b = "sudo borgmatic";
          bb = "sudo borgmatic borg";
          bc = "sudo borgmatic create --progress --stats";
          be = "sudo borgmatic extract --progress";
          bi = "sudo borgmatic init -e repokey-blake2";
          bk = "sudo borgmatic key export";
          bl = "sudo borgmatic list";
          bm = "sudo borgmatic mount";
          brl = "sudo borgmatic rlist";
          br = "sudo borgmatic restore";
          bt = "sudo borgmatic export-tar";
          bu = "sudo borgmatic unmount";

          c = "clear";
          e = "exit";
          m = "mosh";

          d = "docker";
          dc = "docker compose";
          dcd = "docker compose down";
          dce = "docker compose exec";
          dcl = "docker compose logs";
          dcp = "docker compose pull";
          dcu = "docker compose up";
          dcuf = "docker compose up --force-recreate";
          de = "docker exec";
          dei = "docker exec --interactive";
          deit = "docker exec --interactive --tty";
          det = "docker exec --tty";
          di = "docker images";
          dk = "docker kill";
          dn = "docker network";
          dnl = "docker network ls";
          dp = "docker pull";
          dps = "docker ps";
          dpsa = "docker ps --all --size";
          dr = "docker rm";
          ds = "docker system";
          dsp = "docker system prune";
          dspav = "docker system prune --all --volumes";

          g = "git";
          ga = "git add";
          gb = "git branch";
          gbi = "git bisect";
          gbib = "git bisect bad";
          gbig = "git bisect good";
          gc = "git clone";
          gd = "git diff";
          gf = "git fetch";
          gi = "git init";
          gk = "git checkout";
          gl = "git log";
          gm = "git merge";
          gp = "git pull";
          gps = "git push";
          gr = "git reset";
          grh = "git reset --hard";
          grb = "git rebase";
          grm = "git rm";
          grt = "git remote";
          grv = "git revert";
          gs = "git status";
          gsh = "git show";
          gst = "git stash";
          gsw = "git switch";
          gy = "git cherrypick";

          jc = "journalctl";
          jcs = "journalctl --system";
          jcse = "journalctl --system --pager-end";
          jcsei = "journalctl --user --pager-end --identifier";
          jcseu = "journalctl --system --pager-end --unit";
          jcsf = "journalctl --system --follow";
          jcsfi = "journalctl --user --follow --identifier";
          jcsfu = "journalctl --system --follow --unit";
          jcsi = "journalctl --system --identifier";
          jcsu = "journalctl --system --unit";
          jcu = "journalctl --user";
          jcue = "journalctl --user --pager-end";
          jcuei = "journalctl --user --pager-end --identifier";
          jcueu = "journalctl --user --pager-end --unit";
          jcuf = "journalctl --user --follow";
          jcufi = "journalctl --user --follow --identifier";
          jcufu = "journalctl --user --follow --unit";
          jcui = "journalctl --user --identifier";
          jcuu = "journalctl --user --unit";

          k = "kitten";
          ks = "kitten ssh";

          n = "nixos";
          nb = "nixos build";
          nbb = "nixos build boot";
          nbs = "nixos build switch";
          nbt = "nixos build test";
          nd = "nixos diff";
          ng = "nixos generate";
          nl = "nixos list";
          nr = "nixos repl";

          sc = "systemctl";
          scp = "systemctl poweroff";
          scr = "systemctl reboot";
          scs = "systemctl --system";
          scsd = "systemctl --system disable";
          scsdn = "systemctl --system disable --now";
          scse = "systemctl --system reenable";
          scsen = "systemctl --system reenable --now";
          scsh = "systemctl --system show";
          scsl = "systemctl --system list-unit-files";
          scsm = "systemctl --system mask";
          scsr = "systemctl --system restart";
          scsrr = "systemctl --system reload-or-restart";
          scss = "systemctl --system status";
          scst = "systemctl --system stop";
          scsu = "systemctl --system unmask";
          scu = "systemctl --user";
          scud = "systemctl --user disable";
          scudn = "systemctl --user disable --now";
          scue = "systemctl --user reenable";
          scuen = "systemctl --user reenable --now";
          scuh = "systemctl --user show";
          scul = "systemctl --user list-unit-files";
          scum = "systemctl --user mask";
          scur = "systemctl --user restart";
          scurr = "systemctl --user reload-or-restart";
          scus = "systemctl --user status";
          scut = "systemctl --user stop";
          scuu = "systemctl --user unmask";

          s = "ssh";
          si = "ssh -o KexAlgorithms=+diffie-hellman-group1-sha1 -o HostkeyAlgorithms=+ssh-rsa -o Ciphers=aes256-cbc";

          ta = "tmux attach";
          td = "tmux detach";
          tk = "tmux kill-session";
          tl = "tmux list-sessions";

          ts = "tailscale";
          tsip = "tailscale ip --4";

          zt = "sudo zerotier-cli";
          ztip = "sudo zerotier-cli get $(sudo zerotier-cli -j listnetworks | jq -r .[-1].id) ip";
        };

        interactiveShellInit = ''
          ### Prompt
          # Disable greeting
          set -g fish_greeting

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

          ### Interactive
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
        '';
      };
    };
  };
}
