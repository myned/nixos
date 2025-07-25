{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.containers.mullvad;

  cp = getExe' pkgs.coreutils "cp";
  curl = getExe pkgs.curl;
  jq = getExe pkgs.jq;
  mkdir = getExe' pkgs.coreutils "mkdir";
  printf = getExe' pkgs.coreutils "printf";
  shuf = getExe' pkgs.coreutils "shuf";
in {
  options.custom.containers.mullvad = {
    enable = mkEnableOption "mullvad";

    gluetun = mkOption {
      description = "Whether to use gluetun as the WireGuard client";
      default = true;
      example = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    #?? arion-mullvad pull
    environment.shellAliases.arion-mullvad = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.mullvad.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.mullvad.settings.services = {
      mullvad.service =
        # https://github.com/qdm12/gluetun
        # https://github.com/qdm12/gluetun-wiki
        optionalAttrs cfg.gluetun {
          container_name = "mullvad";
          devices = ["/dev/net/tun:/dev/net/tun"];
          env_file = [config.age.secrets."${config.custom.hostname}/mullvad/gluetun.env".path];
          hostname = "${config.custom.hostname}-mullvad";
          image = "qmcgaw/gluetun:v3.40.0"; # https://hub.docker.com/r/qmcgaw/gluetun/tags
          restart = "unless-stopped";

          capabilities = {
            NET_ADMIN = true;
            NET_RAW = true;
          };
        }
        # https://github.com/linuxserver/docker-wireguard
        // optionalAttrs (!cfg.gluetun) {
          container_name = "mullvad";
          devices = ["/dev/net/tun:/dev/net/tun"];
          hostname = "${config.custom.hostname}-mullvad";
          image = "ghcr.io/linuxserver/wireguard:1.0.20210914"; # https://github.com/linuxserver/docker-wireguard/pkgs/container/wireguard
          restart = "unless-stopped";
          volumes = ["${config.custom.containers.directory}/mullvad/config:/config"];

          capabilities = {
            NET_ADMIN = true;
            NET_RAW = true;
          };

          sysctls = {
            "net.ipv4.conf.all.src_valid_mark" = 1;
          };
        };
    };

    # https://github.com/linuxserver/docker-wireguard?tab=readme-ov-file#note-on-iptables
    # Alternative: capabilities: SYS_MODULE with /lib/modules:/lib/modules mount
    # boot.kernelModules = [
    #   "iptable_raw"
    #   "ip6table_raw"
    # ];

    systemd = optionalAttrs (!cfg.gluetun) {
      services.arion-mullvad-randomize = {
        description = "Randomly select a Mullvad relay";
        requires = ["arion-mullvad.service"];

        script = ''
          ${mkdir} -p ${config.custom.containers.directory}/mullvad/config/wg_confs
          cd ${config.custom.containers.directory}/mullvad/config

          # Gather relay list
          ${curl} https://api.mullvad.net/www/relays/all > relays.json

          # Filter results by relevance and randomly select one
          ${jq} -c '.[] | select(.active == true and .type == "wireguard" and .country_code == "us")' relays.json | ${shuf} -n 1 > random.json

          # Write selected relay as WireGuard configuration
          ${cp} -f ${config.age.secrets."${config.custom.hostname}/mullvad/wireguard.conf".path} wg_confs/wireguard.conf
          ${printf} "\n[Peer]\nPublicKey = $(${jq} -r .pubkey random.json)\nAllowedIPs = 0.0.0.0/0,::0/0\nEndpoint = $(${jq} -r .ipv4_addr_in random.json):51820\n" >> wg_confs/wireguard.conf
        '';
      };

      timers.arion-mullvad-randomize = {
        description = "Randomly select a Mullvad relay daily";
        wantedBy = ["timers.target"];

        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };
    };

    age.secrets = listToAttrs (map (name: {
        inherit name;
        value = {file = "${inputs.self}/secrets/${name}";};
      })
      (optionals cfg.gluetun [
          "${config.custom.hostname}/mullvad/gluetun.env"
        ]
        ++ optionals (!cfg.gluetun) [
          "${config.custom.hostname}/mullvad/wireguard.conf"
        ]));
  };
}
