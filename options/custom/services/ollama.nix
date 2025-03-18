{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.ollama;
in {
  options.custom.services.ollama = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://ollama.com/
    # https://wiki.nixos.org/wiki/Ollama
    services.ollama = {
      enable = true;
      openFirewall = true;

      # https://wiki.nixos.org/wiki/Ollama#AMD_GPU_with_open_source_driver
      # https://github.com/ollama/ollama/blob/main/docs/gpu.md#overrides
      #?? nix run nixpkgs#rocmPackages.rocminfo | grep gfx
      rocmOverrideGfx = with config.custom.settings.hardware; mkIf (isString rocm) rocm;
    };
  };
}
