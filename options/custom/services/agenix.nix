{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cat = "${pkgs.coreutils}/bin/cat";
  sed = "${pkgs.gnused}/bin/sed";

  cfg = config.custom.services.agenix;
in
{
  options.custom.services.agenix.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    xdg.configFile."hypr/hyprland.conf".force = true;

    # Replace placeholders with secrets after agenix user service starts
    systemd.user.services.secrets = {
      Unit = {
        Description = "Replace agenix secrets in-place";
        After = "agenix.service";
      };

      Service = {
        ExecStart = pkgs.writeShellScript "secrets" ''
          file="${config.custom.homeDirectory}/.config/hypr/hyprland.conf"

          ${sed} -i "s|@BW_CLIENTID@|$(${cat} ${
            config.age.secrets."desktop/bitwarden/client_id".path
          })|" "$file"
          ${sed} -i "s|@BW_CLIENTSECRET@|$(${cat} ${
            config.age.secrets."desktop/bitwarden/client_secret".path
          })|" "$file"
        '';
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
