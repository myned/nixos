{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.services.ollama;
in {
  options.custom.services.ollama = {
    enable = mkEnableOption "ollama";

    download = mkOption {
      description = "List of model performance levels that contain models to download";
      default = null;
      example = ["low" "medium"];
      type = with types; listOf (enum ["potato" "low" "medium" "high" "extreme"]);
    };

    server = mkOption {
      description = "Host of the remote server that serves models, used in client modules";
      default = "localhost";
      example = "127.0.0.1";
      type = types.str;
    };

    models = {
      agent = mkOption {
        description = "Default model used for multimodal agentic workflows";
        default = findFirst (model: hasInfix "qwen" model) null (reverseList config.services.ollama.loadModels);
        example = "qwen3.5:9b";
        type = types.str;
      };

      completion = mkOption {
        description = "Default model used for predictive text generation";
        default = findFirst (model: hasInfix "qwen" model) null config.services.ollama.loadModels;
        example = "qwen3.5:2b";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    # https://ollama.com/
    # https://wiki.nixos.org/wiki/Ollama
    services.ollama = {
      enable = true;
      package = pkgs.unstable.ollama-vulkan; # Generic GPU support
      host = "[::]";
      port = 11434; # TCP
      syncModels = true; # Remove undeclared models

      #!! Downloads on activation
      # https://ollama.com/search
      # https://llm-stats.com/leaderboards/llm-leaderboard
      loadModels = naturalSort (
        # < 2B parameters
        optionals (elem "potato" cfg.download) [
          "qwen3.5:0.8b"
        ]
        # >= 2B < 4B parameters
        ++ optionals (elem "low" cfg.download) [
          "qwen3.5:2b"
        ]
        # >= 4B < 8B parameters
        ++ optionals (elem "medium" cfg.download) [
          "fluffy/l3-8b-stheno-v3.2:q4_K_S"
          "qwen3.5:4b"
        ]
        # >= 8B < 16B parameters
        ++ optionals (elem "high" cfg.download) [
          "fluffy/l3-8b-stheno-v3.2:q8_0"
          "qwen3.5:9b"
        ]
        # >= 16B parameters
        ++ optionals (elem "extreme" cfg.download) [
          "qwen3.5:27b"
        ]
      );

      # https://docs.ollama.com/
      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = "16384"; # https://docs.ollama.com/context-length
        OLLAMA_FLASH_ATTENTION = "1"; # https://docs.ollama.com/faq#how-can-i-enable-flash-attention
        OLLAMA_KEEP_ALIVE = "1h"; # https://docs.ollama.com/faq#how-do-i-keep-a-model-loaded-in-memory-or-make-it-unload-immediately
        OLLAMA_KV_CACHE_TYPE = "q4_0"; # https://docs.ollama.com/faq#how-can-i-set-the-quantization-type-for-the-k/v-cache
        OLLAMA_MAX_LOADED_MODELS = "2"; # https://docs.ollama.com/faq#how-does-ollama-handle-concurrent-requests
        OLLAMA_NO_CLOUD = "1"; # https://docs.ollama.com/faq#how-do-i-disable-ollama%E2%80%99s-cloud-features
      };
    };
  };
}
