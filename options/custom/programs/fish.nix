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

      ${config.custom.username}.programs.fish = {
        enable = true;

        shellAbbrs =
          # Expand abbreviations anywhere in the shell
          #?? sudo ABBREVIATION
          mapAttrs (name: value: {
            expansion = value;
            position = "anywhere";
            setCursor = true;
          }) {
            "/e" = "/etc/%";
            "/en" = "/etc/nixos/%";
            "/h" = "~/%";
            "/hd" = "~/.dev/%";
            "/n" = "/nix/%";
            "/nv" = "/nix/var/%";
            "/nvn" = "/nix/var/nix/%";
            "/nvnp" = "/nix/var/nix/profiles/%";
            "/nvnps" = "/nix/var/nix/profiles/system/%";
            "/r" = "/run/%";
            "/rc" = "/run/current-system/%";
          }
          //
          # Set all cursor positions to %
          #?? % | EXPANSION
          mapAttrs (name: value: {
            expansion = value;
            setCursor = true;
          }) {
            reboot = "sudo systemctl reboot";
            restart = "sudo systemctl reboot";
            poweroff = "sudo systemctl poweroff";
            shutdown = "sudo systemctl poweroff";

            rsync = "rsync --info progress2";

            a = "adb";
            as = "adb shell";
            asa = "adb shell sh /sdcard/Android/data/com.llamalab.automate/cache/start.sh"; # Automate

            b = "sudo borgmatic --progress --stats";
            bb = "sudo borgmatic borg";
            bc = "sudo borgmatic create --progress --stats";
            bct = "sudo borgmatic compact";
            be = "sudo borgmatic extract --progress";
            bi = "sudo borgmatic info";
            bin = "sudo borgmatic init -e repokey-blake2";
            bk = "sudo borgmatic key export";
            bl = "sudo borgmatic list";
            bm = "sudo borgmatic mount";
            bp = "sudo borgmatic prune";
            brl = "sudo borgmatic rlist";
            br = "sudo borgmatic restore";
            bt = "sudo borgmatic export-tar";
            bu = "sudo borgmatic unmount";

            c = "clear";
            e = "exit";
            m = "mosh";
            r = "reset";

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
            gco = "git commit";
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

            hy = "hyprctl";
            hyc = "hyprctl clients";
            hycj = "hyprctl -j clients";
            hyd = "hyprctl dispatch";
            hydj = "hyprctl -j dispatch";
            hydv = "hyprctl devices";
            hydvj = "hyprctl -j devices";
            hyj = "hyprctl -j";
            hyk = "hyprctl keyword";
            hykj = "hyprctl -j keyword";
            hyl = "hyprctl rollinglog";
            hylj = "hyprctl -j rollinglog";
            hym = "hyprctl monitors";
            hymj = "hyprctl -j monitors";
            hyo = "hyprctl output";
            hyoj = "hyprctl -j output";
            hyr = "hyprctl reload";
            hyrj = "hyprctl -j reload";
            hys = "hyprctl setprop";
            hysj = "hyprctl -j setprop";
            hyv = "hyprctl version";
            hyvj = "hyprctl -j version";

            jc = "journalctl";
            jcei = "journalctl --pager-end --identifier";
            jcfi = "journalctl --follow --identifier";
            jci = "journalctl --identifier";
            jcs = "journalctl --system";
            jcse = "journalctl --system --pager-end";
            jcsei = "journalctl --user --pager-end --identifier";
            jcseu = "journalctl --system --pager-end --unit";
            jcsf = "journalctl --system --follow";
            jcsfu = "journalctl --system --follow --unit";
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

            n = "nix";
            nb = "nix build";
            nd = "nix develop";
            nf = "nix flake";
            nfi = "nix flake info";
            nfl = "nix flake lock";
            nfu = "nix flake update";
            nr = "nix run";
            nrgl = "nix run github:nix-community/nixGL --impure -- %";
            nrn = "nix run nixpkgs#%";
            ns = "nix shell";
            nsgl = "nix shell github:nix-community/nixGL --impure";
            nsn = "nix shell nixpkgs#%";
            nt = "nix store";

            ni = "niri";
            nim = "niri msg";
            nima = "niri msg action";
            nimaj = "niri msg --json action";
            nimfo = "niri msg focused-output";
            nimfoj = "niri msg --json focused-output";
            nimfw = "niri msg focused-window";
            nimfwj = "niri msg --json focused-window";
            nimj = "niri msg --json";
            niml = "niri msg layers";
            nimlj = "niri msg --json layers";
            nimo = "niri msg output";
            nimoj = "niri msg --json output";
            nimos = "niri msg outputs";
            nimosj = "niri msg --json outputs";
            nimv = "niri msg version";
            nimvj = "niri msg --json version";
            nimw = "niri msg windows";
            nimwj = "niri msg --json windows";
            nimwk = "niri msg workspaces";
            nimwkj = "niri msg --json workspaces";

            os = "nixos";
            osb = "nixos build";
            osbb = "nixos build boot";
            osbs = "nixos build switch";
            osbt = "nixos build test";
            osd = "nixos diff";
            osg = "nixos generate";
            osl = "nixos list";
            osr = "nixos repl";

            sc = "systemctl";
            scp = "sudo systemctl poweroff";
            scr = "sudo systemctl reboot";
            scs = "sudo systemctl --system";
            scsd = "sudo systemctl --system disable";
            scsdn = "sudo systemctl --system disable --now";
            scse = "sudo systemctl --system reenable";
            scsen = "sudo systemctl --system reenable --now";
            scsh = "sudo systemctl --system show";
            scsl = "sudo systemctl --system list-unit-files";
            scsm = "sudo systemctl --system mask";
            scsr = "sudo systemctl --system restart";
            scsrr = "sudo systemctl --system reload-or-restart";
            scss = "sudo systemctl --system status";
            scst = "sudo systemctl --system stop";
            scsu = "sudo systemctl --system unmask";
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

            t = "tailscale";
            td = "sudo tailscale down";
            te = "sudo tailscale exit-node";
            ti = "tailscale ip --4";
            tl = "sudo tailscale login";
            tp = "tailscale ping";
            ts = "tailscale status";
            tss = "tailscale ssh";
            tt = "sudo tailscale set";
            tu = "sudo tailscale up";
            tw = "sudo tailscale switch";

            txa = "tmux attach";
            txd = "tmux detach";
            txk = "tmux kill-session";
            txl = "tmux list-sessions";

            w = "waydroid";
            wa = "waydroid app";
            waa = "waydroid app launch com.YoStarEN.Arknights"; # Arknights
            wap = "waydroid app launch com.android.vending"; # Play Store
            was = "waydroid app launch com.android.settings"; # Settings
            wf = "waydroid show-full-ui";
            wi = "sudo waydroid init --force --system_type GAPPS";
            ws = "waydroid session";
            wsh = "sudo waydroid shell";
            wss = "waydroid session start &> /dev/null & disown";
            wst = "waydroid session stop";
            wu = "sudo waydroid upgrade";

            z = "sudo zerotier-cli";
            zi = "sudo zerotier-cli get $(sudo zerotier-cli -j listnetworks | jq -r .[-1].id) ip";
          };

        interactiveShellInit = ''
          # Disable greeting
          set -g fish_greeting
        '';
      };
    };
  };
}
