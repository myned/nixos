{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.zerotierone;
in {
  options.custom.services.zerotierone.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    #!! Configuration is imperative
    # https://www.zerotier.com/
    # https://github.com/zerotier/ZeroTierOne
    services.zerotierone = {
      enable = true;
    };
  };
}
