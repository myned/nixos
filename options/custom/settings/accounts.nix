{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.accounts;
in {
  options.custom.settings.accounts.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    accounts = {
      email.accounts.${config.custom.username} = {
        primary = true;
        address = "${config.custom.username}@${config.custom.domain}";
        realName = config.custom.realname;
        userName = "${config.custom.username}@${config.custom.domain}";

        imap = {
          host = "imap.fastmail.com";
          port = 993;
        };

        smtp = {
          host = "smtp.fastmail.com";
          port = 465;
        };
      };
    };
  };
}
