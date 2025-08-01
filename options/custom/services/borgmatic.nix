{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cat = "${pkgs.coreutils}/bin/cat";

  cfg = config.custom.services.borgmatic;
in {
  # https://wiki.nixos.org/wiki/Borg_backup
  # https://github.com/borgmatic-collective/borgmatic
  #!! Imperative initialization
  #?? sudo borgmatic init -e repokey-blake2
  #?? sudo borgmatic key export
  #?? sudo borgmatic -v 1 create --progress --stats
  options.custom.services.borgmatic = {
    enable = mkEnableOption "borgmatic";

    repositories = mkOption {
      default = [];
      type = with types; listOf str;
    };

    sources = mkOption {
      default = [];
      type = with types; listOf str;
    };
  };

  config = mkIf cfg.enable {
    services.borgmatic = {
      enable = true;

      # https://torsion.org/borgmatic/docs/reference/configuration/
      settings = {
        keep_hourly = 1;
        keep_daily = 1;
        keep_weekly = 1;
        keep_monthly = 1;
        keep_yearly = 0;
        retries = 10;
        retry_wait = 60; # Additive seconds per retry
        compression = "auto,zstd"; # Use heuristics to decide whether to compress with zstd
        ssh_command = "ssh -i /etc/ssh/id_ed25519"; #!! Imperative key generation
        encryption_passcommand = "${cat} ${config.age.secrets."${config.custom.hostname}/borgmatic/borgbase".path}";
        source_directories = cfg.sources;

        #!! Assume separate repository for each profile
        repositories = forEach cfg.repositories (repository: {
          label = config.custom.profile;
          path = repository;
        });

        # TODO: Add more databases
        #?? sudo borgmatic restore --archive latest
        # postgresql_databases = [
        #   {
        #     name = "nextcloud";
        #     username = "nextcloud";
        #     pg_dump_command = "docker exec -i nextcloud-db pg_dump";
        #     pg_restore_command = "docker exec -i nextcloud-db pg_restore";
        #     psql_command = "docker exec -i nextcloud-db psql";
        #   }

        #   {
        #     name = "piped";
        #     username = "piped";
        #     pg_dump_command = "docker exec -i postgres pg_dump";
        #     pg_restore_command = "docker exec -i postgres pg_restore";
        #     psql_command = "docker exec -i postgres psql";
        #   }
        # ];
      };
    };

    age.secrets = let
      secret = filename: {file = "${inputs.self}/secrets/${filename}";};
    in {
      "${config.custom.hostname}/borgmatic/borgbase" = secret "${config.custom.hostname}/borgmatic/borgbase";
    };
  };
}
