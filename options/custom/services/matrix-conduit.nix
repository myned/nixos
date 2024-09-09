{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.services.matrix-conduit;
in
{
  options.custom.services.matrix-conduit.enable = mkOption { default = false; };

  config = mkIf cfg.enable {
    age.secrets =
      let
        secret = filename: {
          file = "${inputs.self}/secrets/${filename}";
          owner = "300";
          group = "300";
        };
      in
      {
        "${config.custom.profile}/matrix-conduit/conduwuit.toml" = secret "${config.custom.profile}/matrix-conduit/conduwuit.toml";
      };

    # https://wiki.nixos.org/wiki/Matrix
    # https://conduwuit.puppyirl.gay/deploying/nixos.html
    # https://github.com/girlbossceo/conduwuit
    services.matrix-conduit = {
      enable = true;
      package = inputs.conduwuit.packages.${pkgs.system}.default-debug; # !! Debug build
    };

    # Bind conduwuit service to media mount
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/matrix/conduit.nix#L113
    systemd.services.conduit =
      let
        mount = "mnt-remote-conduwuit.mount";
      in
      {
        after = [ mount ];
        bindsTo = [ mount ];

        # Override with static uid for media mount
        serviceConfig.User = lib.mkForce "300"; # 400-499 is reserved for system users

        # Override module's attempt to use conduit default config
        # https://github.com/girlbossceo/conduwuit/blob/main/conduwuit-example.toml
        environment = lib.mkForce {
          CONDUWUIT_CONFIG = config.age.secrets."${config.custom.profile}/matrix-conduit/conduwuit.toml".path;
        };
      };

    # Create bind mount to remote media in lieu of conduwuit.toml setting
    # https://nixos.wiki/wiki/Filesystems#Bind_mounts
    fileSystems."/var/lib/matrix-conduit/media" = {
      device = "/mnt/remote/conduwuit/media";
      fsType = "none";
      options = [ "bind" ];
    };
  };
}
