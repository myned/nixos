{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.proton;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.proton = {
    enable = mkEnableOption "proton";

    branch = mkOption {
      description = "Branch from which to install Proton packages";
      default = "unstable";
      example = "stable";
      type = types.enum ["stable" "unstable"];
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs.${cfg.branch}; [
      proton-authenticator
      proton-pass
      proton-pass-cli
      proton-vpn
      proton-vpn-cli
      protonmail-desktop
    ];

    home-manager.sharedModules = [
      {
        # TODO: Enable when released in stable
        # services.proton-pass-agent = {
        #   enable = true;
        #   package = pkgs.${cfg.branch}.proton-pass-cli;
        # };

        # services.protonmail-bridge = {
        #   enable = true;
        #   package = pkgs.${cfg.branch}.protonmail-bridge;
        # };
      }
    ];
  };
}
