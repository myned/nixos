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

      # Bind to all interfaces, but only Tailscale can access the closed port
      # https://github.com/ollama/ollama/blob/main/docs/faq.md#how-can-i-expose-ollama-on-my-network
      host = "0.0.0.0";
      #// openFirewall = true; # 11434/tcp

      environmentVariables = {
        # https://github.com/ollama/ollama/blob/main/docs/faq.md#how-can-i-specify-the-context-window-size
        OLLAMA_CONTEXT_LENGTH = "8192";
      };

      # https://wiki.nixos.org/wiki/Ollama#AMD_GPU_with_open_source_driver
      # https://github.com/ollama/ollama/blob/main/docs/gpu.md#overrides
      #?? nix run nixpkgs#rocmPackages.rocminfo | grep gfx
      rocmOverrideGfx = with config.custom.settings.hardware; mkIf (isString rocm) rocm;
    };
  };
}
