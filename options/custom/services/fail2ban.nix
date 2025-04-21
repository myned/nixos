{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.fail2ban;
in {
  options.custom.services.fail2ban = {
    enable = mkEnableOption "fail2ban";
  };

  config = mkIf cfg.enable {
    # TODO: Add more jails
    # https://wiki.nixos.org/wiki/Fail2ban
    # https://fail2ban.readthedocs.io/en/latest/filters.html
    services.fail2ban = {
      enable = true;
    };
  };
}
