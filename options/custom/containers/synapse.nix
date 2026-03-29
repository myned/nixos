{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.containers.synapse;
  containerCfg = config.containers.synapse;
  hostCfg = config;
in {
  options.custom.containers.synapse = {
    enable = mkEnableOption "synapse";
  };

  config = mkIf cfg.enable {
    containers.synapse = {
      agenix.secrets = optionals containerCfg.agenix.enable [
        "${hostCfg.custom.hostname}/synapse/extra.yaml"
        "${hostCfg.custom.hostname}/synapse/livekit.key.yaml"
      ];

      # Mount data directory for media store
      bindMounts = mkIf (containerCfg.dataDir != null) {
        "${containerCfg.config.services.matrix-synapse.dataDir}:idmap" = {
          hostPath = containerCfg.dataDir;
          isReadOnly = false;
        };
      };

      config = {
        services = {
          # https://wiki.nixos.org/wiki/Matrix
          # https://nixos.org/manual/nixos/stable/index.html#module-services-matrix-synapse
          matrix-synapse = {
            enable = true;
            extraConfigFiles = optionals containerCfg.agenix.enable [hostCfg.age.secrets."${hostCfg.custom.hostname}/synapse/extra.yaml".path];

            # https://element-hq.github.io/synapse/latest/usage/configuration/config_documentation.html
            # https://github.com/element-hq/synapse/blob/develop/docs/sample_config.yaml
            # https://github.com/element-hq/element-call/blob/livekit/docs/self-hosting.md
            #?? https://matrix.org/federationtester
            settings = {
              admin_contact = "mailto:admin@${hostCfg.custom.domain}";
              default_room_version = "12";
              delete_stale_devices_after = "1y";
              enable_registration = true;
              encryption_enabled_by_default_for_room_type = "invite";
              forget_rooms_on_leave = true;
              forgotten_room_retention_period = "7d";
              include_profile_data_on_invite = false;
              limit_profile_requests_to_users_who_share_rooms = true;
              max_event_delay_duration = "24h";
              max_upload_size = "100M";
              media_retention.local_media_lifetime = null;
              media_retention.remote_media_lifetime = "7d";
              media_store_path = "${containerCfg.config.services.matrix-synapse.dataDir}/media_store";
              public_baseurl = "https://matrix.${hostCfg.custom.domain}/";
              rc_delayed_event_mgmt.burst_count = 20;
              rc_delayed_event_mgmt.per_second = 1;
              rc_message.burst_count = 30;
              rc_message.per_second = 0.5;
              redaction_retention_period = "0";
              registration_requires_token = true;
              registrations_require_3pid = ["email"];
              report_stats = true; #!! Telemetry
              require_auth_for_profile_requests = true;
              retention.enabled = true; # https://element-hq.github.io/synapse/latest/message_retention_policies.html
              room_list_publication_rules = [{action = "allow";}];
              server_name = hostCfg.custom.domain; # https://element-hq.github.io/synapse/latest/federate.html
              server_notices.auto_join = true; # https://element-hq.github.io/synapse/latest/server_notices.html
              server_notices.room_name = "Nowotices";
              server_notices.room_topic = "Notices from this homeserver";
              server_notices.system_mxid_display_name = "System";
              server_notices.system_mxid_localpart = "system";
              signing_key_path = "${containerCfg.config.services.matrix-synapse.dataDir}/matrix.${hostCfg.custom.domain}.signing.key";
              suppress_key_server_warning = true;
              trusted_key_servers = [{server_name = "matrix.org";}];
              url_preview_enabled = true;
              url_preview_url_blacklist = [{scheme = "http";}]; # HTTPS only
              user_directory.enabled = true;
              user_directory.prefer_local_users = true;
              user_directory.search_all_users = true;
              user_directory.show_locked_users = true;
              web_client_location = "https://element.${hostCfg.custom.domain}/";

              url_preview_ip_range_blacklist = [
                "::1/128"
                "10.0.0.0/8"
                "100.64.0.0/10"
                "127.0.0.0/8"
                "169.254.0.0/16"
                "172.16.0.0/12"
                "192.0.0.0/24"
                "192.0.2.0/24"
                "192.168.0.0/16"
                "192.88.99.0/24"
                "198.18.0.0/15"
                "198.51.100.0/24"
                "2001:db8::/32"
                "203.0.113.0/24"
                "224.0.0.0/4"
                "fc00::/7"
                "fe80::/10"
                "fec0::/10"
                "ff00::/8"
              ];

              listeners = [
                {
                  bind_addresses = ["::" "0.0.0.0"];
                  port = 8008; # TCP
                  tls = false;
                  type = "http";
                  x_forwarded = true;

                  resources = [
                    {
                      names = ["client" "federation"];
                      compress = false;
                    }
                  ];
                }
              ];

              # https://element-hq.github.io/synapse/latest/admin_api/experimental_features.html
              # https://github.com/element-hq/synapse/issues?q=state%3Aopen%20label%3AT-ExperimentalFeature
              # https://github.com/element-hq/synapse/blob/develop/synapse/config/experimental.py#L369
              # https://github.com/element-hq/element-web/blob/develop/docs/labs.md
              # https://github.com/matrix-org/matrix-spec-proposals
              experimental_features = {
                msc3266_enabled = true; # Room summary API
                msc4222_enabled = true; # Adding state_after to /sync
              };
            };
          };

          # https://wiki.nixos.org/wiki/PostgreSQL
          postgresql = {
            enable = true;
            package = pkgs.postgresql_17;
            initdbArgs = ["--encoding=UTF8" "--locale=C"]; # https://element-hq.github.io/synapse/latest/postgres.html#fixing-incorrect-collate-or-ctype
            ensureDatabases = ["matrix-synapse"];

            ensureUsers = [
              {
                name = "matrix-synapse";
                ensureDBOwnership = true;
              }
            ];
          };

          # https://wiki.nixos.org/wiki/Matrix#Livekit
          # https://github.com/element-hq/lk-jwt-service
          lk-jwt-service = {
            enable = true;
            port = 8888; # TCP
            livekitUrl = "wss://rtc.${hostCfg.custom.domain}";
            keyFile = mkIf containerCfg.agenix.enable hostCfg.age.secrets."${hostCfg.custom.hostname}/synapse/livekit.key.yaml".path;
          };
        };

        systemd.services.lk-jwt-service = {
          environment.LIVEKIT_FULL_ACCESS_HOMESERVERS = hostCfg.custom.domain; # Restrict JWT access
        };
      };
    };

    age.secrets."${hostCfg.custom.hostname}/synapse/extra.yaml" = {
      owner = "224"; # matrix-synapse
      group = "224"; # matrix-synapse
    };
  };
}
