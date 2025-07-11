{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services.ollama;
in {
  options.custom.services.ollama = {
    enable = mkEnableOption "ollama";

    acceleration = mkOption {
      default = config.custom.full;
      type = types.bool;
    };

    download = mkOption {
      default = null;
      type = with types; nullOr (enum ["low" "medium" "high"]);
    };

    server = mkOption {
      default =
        if config.custom.full
        then "localhost"
        else "mynix";

      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # https://ollama.com/
    # https://wiki.nixos.org/wiki/Ollama
    services.ollama = {
      enable = true;

      acceleration =
        if cfg.acceleration
        then
          (
            with config.custom.settings.hardware.dgpu;
              if driver == "amdgpu"
              then "rocm"
              else if driver == "nvidia" || driver == "nouveau"
              then "cuda"
              else null
          )
        else false; # CPU

      # Bind to all interfaces, but only Tailscale can access the closed port
      # https://github.com/ollama/ollama/blob/main/docs/faq.md#how-can-i-expose-ollama-on-my-network
      host = "0.0.0.0";
      #// openFirewall = true; # 11434/tcp

      #!! Downloads on activation
      # https://ollama.com/search
      loadModels = mkIf (!isNull cfg.download) (
        [
          "codegemma:7b"
          "codellama:7b"
          "deepseek-coder:6.7b"
          "qwen2.5-coder:7b"
        ]
        ++ optionals (cfg.download == "low") [
          "deepseek-r1:1.5b"
          "gemma3:1.5b"
          "llama3.2:1b"
        ]
        ++ optionals (cfg.download == "medium") [
          "gemma3:4b"
          "deepseek-r1:7b"
          "llama3.1:8b"
          "llama3.2:3b"
        ]
        ++ optionals (cfg.download == "high") [
          "deepseek-r1:14b"
          "gemma3:12b"
          "phi4:14b"
          "qwen2.5:14b"
        ]
      );

      environmentVariables = {
        # https://github.com/ollama/ollama/blob/main/docs/faq.md#how-can-i-specify-the-context-window-size
        OLLAMA_CONTEXT_LENGTH = "8192";
      };

      # https://wiki.nixos.org/wiki/Ollama#AMD_GPU_with_open_source_driver
      # https://github.com/ollama/ollama/blob/main/docs/gpu.md#overrides
      #?? nix run nixpkgs#rocmPackages.rocminfo | grep gfx
      #?? echo $HSA_OVERRIDE_GFX_VERSION
      rocmOverrideGfx = with config.custom.settings.hardware; mkIf (isString rocm) rocm;
    };
  };
}
