{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  bash = "${pkgs.bash}/bin/bash";
  cat = "${pkgs.coreutils}/bin/cat";
  sleep = "${pkgs.coreutils}/bin/sleep";

  create_ap = "${
    config.home-manager.users.${config.custom.username}.services.create_ap.package
  }/bin/create_ap";

  cfg = config.custom.services.create_ap;
in {
  options.custom.services.create_ap = {
    enable = mkOption {default = false;};
    internet = mkOption {default = "eth0";};
    wifi = mkOption {default = "wlan0";};
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {file = "${inputs.self}/secrets/${filename}";};
    in {
      "${config.custom.profile}/create_ap/passphrase" = secret "${config.custom.profile}/create_ap/passphrase";
      "${config.custom.profile}/create_ap/ssid" = secret "${config.custom.profile}/create_ap/ssid";
    };

    # https://github.com/lakinduakash/linux-wifi-hotspot
    services.create_ap = {
      enable = true;

      #!! Declare defaults, enable with interfaces and secrets in machine config
      # https://github.com/lakinduakash/linux-wifi-hotspot/blob/master/src/scripts/create_ap.conf
      settings = {
        COUNTRY = "US";
        FREQ_BAND = 5;
        IEEE80211AC = 1;
        IEEE80211AX = 1;
        IEEE80211N = 1;
        NO_HAVEGED = 1; # Obsolete since kernel v5.6
        NO_VIRT = 1;
      };
    };

    # Override service command with decrypted passphrase
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/create_ap.nix
    systemd.services.create_ap.serviceConfig = {
      ExecStartPre = "${sleep} 15s"; # Some cards like Intel force regulatory domain discovery

      ExecStart = let
        configFile = pkgs.writeText "create_ap.conf" (
          generators.toKeyValue {} config.services.create_ap.settings
        );
      in
        mkForce (
          concatStringsSep " " [
            "${bash} -c"
            "'${create_ap}"
            "--config ${configFile}"
            "${cfg.wifi}"
            "${cfg.internet}"
            "$(${cat} ${config.age.secrets."${config.custom.profile}/create_ap/ssid".path})"
            "$(${cat} ${config.age.secrets."${config.custom.profile}/create_ap/passphrase".path})'"
          ]
        );
    };
  };
}
