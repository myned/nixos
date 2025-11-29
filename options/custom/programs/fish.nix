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

    stylix.targets.fish.enable = true;

    home-manager.sharedModules = [
      {
        programs.fish = {
          enable = true;

          # TODO: Move to individual modules
          shellAbbrs =
            # Expand abbreviations anywhere in the shell
            mapAttrs (name: value: {
              expansion = value;
              position = "anywhere";
              setCursor = true;
            }) {
              "/b" = "/boot/%";
              "/bi" = "/bin/%";
              "/c" = "/containers/%";
              "/d" = "/dev/%";
              "/dd" = "/dev/disk/%";
              "/ddb" = "/dev/disk/by-%";
              "/e" = "/etc/%";
              "/en" = "/etc/nixos/%";
              "/h" = "~/%";
              "/h.c" = "~/.config/%";
              "/h.d" = "~/.dev/%";
              "/h.l" = "~/.local/%";
              "/h.lb" = "~/.local/bin/%";
              "/h.ls" = "~/.local/share/%";
              "/h.s" = "~/.ssh/%";
              "/hde" = "~/Desktop/%";
              "/hdo" = "~/Downloads/%";
              "/hdoc" = "~/Documents/%";
              "/hm" = "~/Music/%";
              "/hp" = "~/Pictures/%";
              "/hps" = "~/Pictures/Screenshots/%";
              "/hpub" = "~/Public/%";
              "/hs" = "~/${config.custom.syncDir}/%";
              "/hv" = "~/Videos/%";
              "/m" = "/mnt/%";
              "/ml" = "/mnt/local/%";
              "/mr" = "/mnt/remote/%";
              "/n" = "/nix/%";
              "/nv" = "/nix/var/%";
              "/nvn" = "/nix/var/nix/%";
              "/nvnp" = "/nix/var/nix/profiles/%";
              "/nvnps" = "/nix/var/nix/profiles/system/%";
              "/o" = "/opt/%";
              "/p" = "/proc/%";
              "/r" = "/run/%";
              "/rc" = "/run/current-system/%";
              "/ro" = "/root/%";
              "/s" = "/srv/%";
              "/sy" = "/sys/%";
              "/syc" = "/sys/class/%";
              "/t" = "/tmp/%";
              "/u" = "/usr/%";
              "/ub" = "/usr/bin/%";
              "/v" = "/var/%";
              "/vl" = "/var/lib/%";
              "/vlo" = "/var/log/%";
              "/vr" = "/var/run/%";
            }
            //
            # Set all cursor positions to %
            mapAttrs (name: value: {
              expansion = value;
              setCursor = true;
            }) {
              reboot = "systemctl reboot";
              restart = "systemctl reboot";
              poweroff = "systemctl poweroff";
              shutdown = "systemctl poweroff";

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

              cz = "chezmoi";
              cza = "chezmoi add";
              czaf = "chezmoi add --follow";
              czc = "chezmoi cat";
              czcd = "chezmoi cd";
              czd = "chezmoi diff";
              czdoc = "chezmoi doctor";
              cze = "chezmoi edit";
              czew = "chezmoi edit --watch";
              czey = "chezmoi edit --apply";
              czg = "chezmoi git";
              czi = "chezmoi init";
              czia = "chezmoi init --apply";
              cziam = "chezmoi init --apply myned";
              czm = "chezmoi merge";
              czma = "chezmoi merge-all";
              czr = "chezmoi re-add";
              czs = "chezmoi status";
              czt = "chezmoi chattr --recursive";
              cztn = "chezmoi chattr --recursive noexecutable,noreadonly";
              czu = "chezmoi update";
              czx = "chezmoi execute-template";
              czy = "chezmoi apply";

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
              dpsf = "docker ps --format='table {{.ID}}\\t{{.Names}}\\t{{.Status}}'";
              dr = "docker rm";
              ds = "docker system";
              dsp = "docker system prune";
              dspav = "docker system prune --all --volumes";

              dd = "sudo dd if=% of= status=progress";

              dir = "direnv";
              dira = "direnv allow";
              dire = "direnv edit";
              dirr = "direnv reload";
              dirs = "direnv status";
              dirt = "direnv export";
              dirx = "direnv exec";

              e = "exit";

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

              i = "ip -brief";
              ia = "ip -brief address";
              ias = "ip -brief address show";
              ir = "ip -brief route";
              irs = "ip -brief route show";
              irst = "ip -brief route show table";
              irsta = "ip -brief route show table all";
              i6 = "ip -6 -brief";
              i6a = "ip -6 -brief address";
              i6as = "ip -6 -brief address show";
              i6r = "ip -6 -brief route";
              i6rs = "ip -6 -brief route show";
              i6rst = "ip -6 -brief route show table";
              i6rsta = "ip -6 -brief route show table all";

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

              k = "kill -9";
              kj = "kill -9 (jobs --pid)";

              lg = "lazygit";
              lgb = "lazygit branch";
              lgl = "lazygit log";
              lgt = "lazygit stash";
              lgs = "lazygit status";

              m = "mosh";

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

              ol = "ollama";
              oll = "ollama list";
              olp = "ollama pull";
              olr = "ollama run";
              olrm = "ollama rm";
              ols = "ollama show";
              olsrv = "ollama serve";
              olv = "ollama --version";

              os = "nixos";
              osb = "nixos build";
              osbb = "nixos build boot";
              osbbo = "nixos build boot -- --offline";
              osbs = "nixos build switch";
              osbso = "nixos build switch -- --offline";
              osbt = "nixos build test";
              osbto = "nixos build test -- --offline";
              osd = "nixos diff";
              osg = "nixos generate";
              osl = "nixos list";
              osr = "nixos repl";

              r = "reset";

              rs = "rsync --verbose --info=progress2";

              sc = "sudo systemctl";
              scp = "sudo systemctl poweroff";
              scr = "sudo systemctl reboot";
              scs = "sudo systemctl --system";
              scsd = "sudo systemctl --system disable";
              scsdn = "sudo systemctl --system disable --now";
              scse = "sudo systemctl --system reenable";
              scsen = "sudo systemctl --system reenable --now";
              scsld = "sudo systemctl --system list-dependencies";
              scsls = "sudo systemctl --system list-sockets";
              scslt = "sudo systemctl --system list-timers";
              scslu = "sudo systemctl --system list-units";
              scsluf = "sudo systemctl --system list-unit-files";
              scsm = "sudo systemctl --system mask";
              scsr = "sudo systemctl --system restart";
              scsrr = "sudo systemctl --system reload-or-restart";
              scss = "sudo systemctl --system status";
              scssh = "sudo systemctl --system show";
              scst = "sudo systemctl --system stop";
              scsu = "sudo systemctl --system unmask";
              scu = "systemctl --user";
              scud = "systemctl --user disable";
              scudn = "systemctl --user disable --now";
              scue = "systemctl --user reenable";
              scuen = "systemctl --user reenable --now";
              sculd = "systemctl --user list-dependencies";
              sculs = "systemctl --user list-sockets";
              scult = "systemctl --user list-timers";
              sculu = "systemctl --user list-units";
              sculuf = "systemctl --user list-unit-files";
              scum = "systemctl --user mask";
              scur = "systemctl --user restart";
              scurr = "systemctl --user reload-or-restart";
              scus = "systemctl --user status";
              scush = "systemctl --user show";
              scut = "systemctl --user stop";
              scuu = "systemctl --user unmask";

              s = "ssh";
              si = "ssh -o KexAlgorithms=+diffie-hellman-group1-sha1 -o HostkeyAlgorithms=+ssh-rsa -o Ciphers=aes256-cbc";

              t = "tailscale";
              t4 = "tailscale ip --4";
              t6 = "tailscale ip --6";
              td = "tailscale down";
              te = "tailscale exit-node";
              ti = "tailscale ip --4 % | wl-copy -n";
              ti4 = "tailscale ip --4 % | wl-copy -n";
              ti6 = "tailscale ip --6 % | wl-copy -n";
              tii = "tailscale ip --6 % | wl-copy -n";
              tl = "tailscale login";
              tlo = "tailscale logout";
              tp = "tailscale ping";
              tn = "tailscale netcheck";
              ts = "tailscale status";
              tss = "tailscale ssh";
              tw = "sudo tailscale switch";
              twl = "sudo tailscale switch --list";
              tt = "tailscale set";
              tu = "tailscale up";
              tuu = "sudo tailscale up --reset --ssh --advertise-exit-node --accept-dns --accept-routes --qr --operator=$USER --auth-key=%";

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

        # https://nix-community.github.io/stylix/options/modules/fish.html
        stylix.targets.fish.enable = true;
      }
    ];
  };
}
