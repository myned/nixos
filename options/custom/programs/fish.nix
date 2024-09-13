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

      shellAbbrs = {
        c = "clear";
        e = "exit";
        m = "mosh";
        s = "ssh";
        i = "tailscale ip --4";

        "/h" = "cd ~";
        "/hd" = "cd ~/.dev";
        "/e" = "cd /etc";
        "/en" = "cd /etc/nixos";
        "/n" = "cd /nix";
        "/nv" = "cd /nix/var";
        "/nvn" = "cd /nix/var/nix";
        "/nvnp" = "cd /nix/var/nix/profiles";
        "/nvnps" = "cd /nix/var/nix/profiles/system";
        "/r" = "cd /run";
        "/rc" = "cd /run/current-system";

        f = "flakegen";
        r = "rebuild";
        rb = "rebuild boot";
        rbp = "rebuild boot && poweroff";
        rbr = "rebuild boot && reboot";
        rs = "rebuild switch";
        rt = "rebuild test";
        t = "target";
        u = "upgrade";
        ub = "upgrade boot";
        ubp = "upgrade boot && poweroff";
        ubr = "upgrade boot && reboot";

        nd = "nvd diff /run/current-system /nix/var/nix/profiles/system";
        no = "nh os";
        nb = "flakegen && nh os boot";
        nbr = "flakegen && nh os boot && reboot";
        nbp = "flakegen && nh os boot && poweroff";
        ns = "flakegen && nh os switch";
        nt = "flakegen && nh os test";

        jc = "journalctl";
        sc = "systemctl";

        d = "docker";
        dc = "docker compose";
        dcd = "docker compose down";
        dce = "docker compose exec";
        dcl = "docker compose logs";
        dcp = "docker compose pull";
        dcu = "docker compose up";
        dcuf = "docker compose up --force-recreate";
        ds = "docker system";

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
  };
}
