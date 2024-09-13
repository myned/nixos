{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.netdata;
in {
  options.custom.services.netdata = {
    enable = mkOption {default = false;};
    parent = mkOption {default = false;};
    child = mkOption {default = false;};
  };

  config = let
    role =
      if cfg.parent
      then "parent"
      else if cfg.child
      then "child"
      else "";
  in
    mkIf cfg.enable {
      # https://github.com/netdata/netdata
      # https://wiki.nixos.org/wiki/Netdata
      services.netdata = {
        enable = true;

        # Override package to include v2 dashboard
        # https://learn.netdata.cloud/docs/developer-and-contributor-corner/redistributed-software
        package = mkIf cfg.parent pkgs.netdata.override {withCloudUi = true;}; # !! NCUL1 non-free license

        # Minimize overhead for children
        # https://learn.netdata.cloud/docs/netdata-agent/configuration/daemon-configuration
        # https://learn.netdata.cloud/docs/netdata-agent/configuration/how-to-optimize-the-netdata-agent-s-performance
        config = {
          global."memory mode" = mkIf cfg.child "ram";
          health.enabled = mkIf cfg.child "no";
          ml.enabled = mkIf cfg.child "no";

          web = {
            mode = mkIf cfg.child "none";
            "enable gzip compression" = "no";
          };
        };

        configDir."stream.conf" =
          mkIf (
            role != ""
          )
          config.age.secrets."${config.custom.profile}/netdata/${role}.conf".path;
      };

      age.secrets = let
        secret = filename: {
          file = "${inputs.self}/secrets/${filename}";
          owner = "netdata";
          group = "netdata";
        };
      in
        mkIf (role != "") {
          "${config.custom.profile}/netdata/${role}.conf" = secret "${config.custom.profile}/netdata/${role}.conf";
        };
    };
}
