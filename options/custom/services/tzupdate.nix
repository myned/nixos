{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.tzupdate;
in {
  options.custom.services.tzupdate.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://github.com/cdown/tzupdate
    services.tzupdate.enable = true;

    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/misc/tzupdate.nix
    systemd.services.tzupdate = {
      # FIXME: Fails at boot, possibly needs to wait for tailscaled.service
      wantedBy = ["network-online.target"]; # Run at boot without checking for Internet access
    };
  };
}
