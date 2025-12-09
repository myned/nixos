{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.ntfy;
  hm = config.home-manager.users.${config.custom.username};

  cat = getExe' pkgs.coreutils "cat";
  notify-send = getExe pkgs.libnotify;
  mv = getExe' pkgs.coreutils "mv";
  sed = getExe pkgs.gnused;
in {
  options.custom.services.ntfy = {
    enable = mkEnableOption "ntfy";

    token = mkOption {
      default = false;
      type = types.bool;
    };

    topics = mkOption {
      default = ["status"];
      type = types.listOf types.str;
    };

    url = mkOption {
      default = "https://notify.${config.custom.domain}";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    age.secrets = let
      secret = filename: {
        file = "${inputs.self}/secrets/${filename}";
        owner = config.custom.username;
        group = config.users.users.${config.custom.username}.group;
      };
    in
      mkIf cfg.token {
        "common/ntfy/token" = secret "common/ntfy/token";
      };

    # https://ntfy.sh/
    # https://github.com/binwiederhier/ntfy
    # https://docs.ntfy.sh/subscribe/cli/
    environment.systemPackages = [pkgs.ntfy-sh];

    # https://github.com/binwiederhier/ntfy/blob/main/client/ntfy-client.service
    systemd.user.services.ntfy-client = {
      description = "ntfy client";
      after = ["network.target"];
      wantedBy = ["default.target"];
      path = [pkgs.busybox]; # ntfy expects sh in the PATH

      serviceConfig = {
        ExecStart = "${getExe' pkgs.ntfy-sh "ntfy"} subscribe --from-config";
        Restart = "on-failure";
      };
    };

    home-manager.sharedModules = [
      {
        xdg.configFile = {
          # TODO: Use official module if available
          # https://github.com/binwiederhier/ntfy/blob/main/client/client.yml
          "ntfy/client.yml" = {
            text = generators.toYAML {} {
              default-host = cfg.url;

              default-command = concatStringsSep " " [
                notify-send
                ''--icon="$NTFY_TAGS"''
                ''"$NTFY_TITLE"''
                ''"$NTFY_MESSAGE"''
              ];

              # https://docs.ntfy.sh/subscribe/cli/#subscribe-to-multiple-topics
              subscribe = forEach cfg.topics (topic:
                {
                  inherit topic;
                }
                // optionalAttrs cfg.token {
                  token = "%PLACEHOLDER%";
                });
            };

            force = true;
          };
        };

        # HACK: Replace placeholder with decrypted token after activation
        home.activation.ntfy = mkIf cfg.token (hm.lib.dag.entryAfter ["writeBoundary"] ''
          run ${sed} \
            "s|%PLACEHOLDER%|$(${cat} ${config.age.secrets."common/ntfy/token".path})|" \
            ${hm.xdg.configFile."ntfy/client.yml".source} \
            > ${hm.xdg.configHome}/ntfy/client.yml.tmp

          run ${mv} \
            ${hm.xdg.configHome}/ntfy/client.yml.tmp ${hm.xdg.configHome}/ntfy/client.yml
        '');
      }
    ];
  };
}
