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
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://ollama.com/
    # https://wiki.nixos.org/wiki/Ollama
    services.ollama = {
      enable = true;
      openFirewall = true;
      package = pkgs.ollama-rocm;

      loadModels = [
        "deepseek-r1" # https://github.com/deepseek-ai/DeepSeek-R1
      ];
    };
  };
}
