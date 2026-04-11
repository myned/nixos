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
      default = null;
      type = with types; listOf (enum ["low" "medium" "high" "uncensored"]);
    };

    server = mkOption {
      default = "localhost";
      type = types.str;
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
      loadModels =
        # <= 4B parameters
        optionals (elem "low" cfg.download) [
          # General/reasoning
          "gemma3:1b" # https://ollama.com/library/gemma3
          "granite3.3:2b" # https://ollama.com/library/granite3.3

          # Code/prediction
          "codegemma:2b" # https://ollama.com/library/codegemma
          "granite-code:3b" # https://ollama.com/library/granite-code
        ]
        # >= 4B <= 8B parameters
        ++ optionals (elem "medium" cfg.download) [
          # General/reasoning
          "gemma3:4b" # https://ollama.com/library/gemma3
          "granite3.3:8b" # https://ollama.com/library/granite3.3
          "ministral-3:8b" # https://ollama.com/library/ministral-3
          "mistral:7b" # https://ollama.com/library/mistral

          # Code/prediction
          "codegemma:7b" # https://ollama.com/library/codegemma
          "granite-code:8b" # https://ollama.com/library/granite-code
        ]
        # >= 8B <= 16B parameters
        ++ optionals (elem "high" cfg.download) [
          # General/reasoning
          "gemma3:12b" # https://ollama.com/library/gemma3
        ]
        ++ optionals (elem "uncensored" cfg.download) [
          # Uncensored/abliterated
          "fluffy/l3-8b-stheno-v3.2:q4_K_M" # https://ollama.com/fluffy/l3-8b-stheno-v3.2
        ];

      environmentVariables = {
        OLLAMA_CONTEXT_LENGTH = "65536"; # https://docs.ollama.com/context-length
        OLLAMA_FLASH_ATTENTION = "1"; # https://docs.ollama.com/faq#how-can-i-enable-flash-attention
        OLLAMA_KEEP_ALIVE = "1h"; # https://docs.ollama.com/faq#how-do-i-keep-a-model-loaded-in-memory-or-make-it-unload-immediately
        OLLAMA_KV_CACHE_TYPE = "q4_0"; # https://docs.ollama.com/faq#how-can-i-set-the-quantization-type-for-the-k/v-cache
        OLLAMA_MAX_LOADED_MODELS = "1"; # https://docs.ollama.com/faq#how-does-ollama-handle-concurrent-requests
        OLLAMA_NO_CLOUD = "1"; # https://docs.ollama.com/faq#how-do-i-disable-ollama%E2%80%99s-cloud-features
      };
    };
  };
}
