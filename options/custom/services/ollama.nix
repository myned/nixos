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
    download = mkOption {default = false;};

    server = mkOption {
      default =
        if config.custom.full
        then "localhost"
        else "mynix";
    };
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

      #!! Downloads on activation
      # https://ollama.com/search
      loadModels = mkIf cfg.download [
        # General
        "deepseek-r1:14b"
        "gemma3:12b"
        "phi4:14b"
        "qwen2.5:14b"

        # Code
        "codegemma:7b"
        "codellama:7b"
        "qwen2.5-coder:7b"
      ];

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
