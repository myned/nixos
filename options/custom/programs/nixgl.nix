{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.nixgl;
in {
  options.custom.programs.nixgl = {
    enable = mkOption {default = false;};
    wrapper = mkOption {default = "mesa";};
  };

  config = mkIf cfg.enable {
    # https://github.com/nix-community/nixGL
    #?? nixGL PROGRAM
    environment.systemPackages = with pkgs.nixgl;
      optionals (cfg.wrapper == "auto") [
        #!! Impure autodetection
        auto.nixGLDefault
      ]
      ++ optionals (cfg.wrapper == "mesa") [
        nixGLIntel
        nixVulkanIntel

        # Wrapper for the wrappers
        #?? nixgl PROGRAM
        (pkgs.writeShellApplication {
          name = "nixgl";
          runtimeInputs = [nixGLIntel nixVulkanIntel];
          text = ''exec nixGLIntel nixVulkanIntel "$@"'';
        })
      ]
      ++ optionals (cfg.wrapper == "nvidia") [
        #!! Impure autodetection
        auto.nixGLNvidia
        auto.nixVulkanNvidia
      ];
  };
}
