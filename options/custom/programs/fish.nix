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
              "/vlm" = "/var/lib/machines/%";
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
              gh = "git show";
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
              iah = "ip -brief address show";
              ir = "ip -brief route";
              irh = "ip -brief route show";
              irht = "ip -brief route show table";
              irhta = "ip -brief route show table all";
              i6 = "ip -6 -brief";
              i6a = "ip -6 -brief address";
              i6ah = "ip -6 -brief address show";
              i6r = "ip -6 -brief route";
              i6rh = "ip -6 -brief route show";
              i6rht = "ip -6 -brief route show table";
              i6rhta = "ip -6 -brief route show table all";

              jc = "sudo journalctl";
              jcei = "sudo journalctl --pager-end --identifier";
              jcfi = "sudo journalctl --follow --identifier";
              jci = "sudo journalctl --identifier";
              jcs = "sudo journalctl --system";
              jcse = "sudo journalctl --system --pager-end";
              jcsem = "sudo journalctl --system --pager-end --machine=%";
              jcsei = "sudo journalctl --user --pager-end --identifier";
              jcseu = "sudo journalctl --system --pager-end --unit";
              jcsf = "sudo journalctl --system --follow";
              jcsfm = "sudo journalctl --system --follow --machine=%";
              jcsfu = "sudo journalctl --system --follow --unit";
              jcsm = "sudo journalctl --system --machine=%";
              jcsu = "sudo journalctl --system --unit";
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

              kc = "kanshictl";
              kcs = "kanshictl switch";
              kcsd = "kanshictl switch default";

              lg = "lazygit";
              lgb = "lazygit branch";
              lgl = "lazygit log";
              lgt = "lazygit stash";
              lgs = "lazygit status";

              m = "mosh";

              mc = "sudo machinectl";
              mcb = "sudo machinectl bind";
              mcc = "sudo machinectl clone";
              mccpf = "sudo machinectl copy-from";
              mccpt = "sudo machinectl copy-to";
              mcd = "sudo machinectl disable";
              mce = "sudo machinectl enable";
              mcexr = "sudo machinectl export-raw";
              mcext = "sudo machinectl export-tar";
              mch = "sudo machinectl show";
              mcis = "sudo machinectl image-status";
              mcimr = "sudo machinectl import-raw";
              mcimt = "sudo machinectl import-tar";
              mck = "sudo machinectl kill";
              mcl = "sudo machinectl list";
              mcli = "sudo machinectl list-images";
              mclo = "sudo machinectl login";
              mclt = "sudo machinectl list-transfers";
              mcp = "sudo machinectl poweroff";
              mcpur = "sudo machinectl pull-raw";
              mcput = "sudo machinectl pull-tar";
              mcr = "sudo machinectl reboot";
              mcre = "sudo machinectl rename";
              mcrm = "sudo machinectl remove";
              mcs = "sudo machinectl status";
              mcsh = "sudo machinectl shell";
              mcshb = "sudo machinectl shell % /run/current-system/sw/bin/";

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

              noc = "sudo nixos-container";
              nocd = "sudo nixos-container destroy";
              noci = "sudo nixos-container show-ip";
              nocl = "sudo nixos-container list";
              noclo = "sudo nixos-container login";
              nocn = "sudo nixos-container run";
              nocr = "sudo nixos-container restart";
              nocrlo = "sudo nixos-container root-login";
              nocs = "sudo nixos-container status";
              noct = "sudo nixos-container stop";
              nocte = "sudo nixos-container terminate";
              nocu = "sudo nixos-container update";

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
              olh = "ollama show";
              oll = "ollama list";
              olp = "ollama pull";
              olps = "ollama ps";
              olr = "ollama run";
              olrm = "ollama rm";
              olsrv = "ollama serve";
              olt = "ollama stop";
              olv = "ollama --version";

              no = "nixos";
              nob = "nixos build";
              nobb = "nixos build boot";
              nobbo = "nixos build boot -- --offline";
              nobs = "nixos build switch";
              nobso = "nixos build switch -- --offline";
              nobt = "nixos build test";
              nobto = "nixos build test -- --offline";
              nod = "nixos diff";
              nog = "nixos generate";
              nol = "nixos list";
              nor = "nixos repl";

              r = "reset";

              rc = "resolvectl";
              rcd = "resolvectl dns";
              rcf = "resolvectl flush-caches";
              rcm = "resolvectl monitor";
              rcq = "resolvectl query";
              rcqc = "resolvectl query --cache=false";
              rcr = "resolvectl revert";
              rcs = "resolvectl status";

              rs = "rsync --verbose --info=progress2";

              s = "ssh";
              si = "ssh -o KexAlgorithms=+diffie-hellman-group1-sha1 -o HostkeyAlgorithms=+ssh-rsa -o Ciphers=aes256-cbc";

              sc = "sudo systemctl";
              scp = "sudo systemctl poweroff";
              scr = "sudo systemctl reboot";
              scs = "sudo systemctl --system";
              scsd = "sudo systemctl --system disable";
              scsdn = "sudo systemctl --system disable --now";
              scse = "sudo systemctl --system reenable";
              scsen = "sudo systemctl --system reenable --now";
              scsh = "sudo systemctl --system show";
              scsld = "sudo systemctl --system list-dependencies";
              scsls = "sudo systemctl --system list-sockets";
              scslt = "sudo systemctl --system list-timers";
              scslu = "sudo systemctl --system list-units";
              scsluf = "sudo systemctl --system list-unit-files";
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
              sculd = "systemctl --user list-dependencies";
              sculs = "systemctl --user list-sockets";
              scult = "systemctl --user list-timers";
              sculu = "systemctl --user list-units";
              sculuf = "systemctl --user list-unit-files";
              scum = "systemctl --user mask";
              scur = "systemctl --user restart";
              scurr = "systemctl --user reload-or-restart";
              scus = "systemctl --user status";
              scut = "systemctl --user stop";
              scuu = "systemctl --user unmask";

              sr = "sudo systemd-run";
              srs = "sudo systemd-run --system";
              srsm = "sudo systemd-run --system --pty --wait --machine=% /run/current-system/sw/bin/";
              srsmsh = "sudo systemd-run --system --shell --machine=%";

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
              wh = "waydroid show-full-ui";
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
