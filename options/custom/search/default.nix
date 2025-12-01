{
  config,
  lib,
  options,
  ...
}:
with lib; let
  cfg = config.custom.search;
in {
  options.custom.search = {
    enable = mkOption {
      description = "Whether to enable search";
      default = config.custom.full;
      example = true;
      type = types.bool;
    };

    default = mkOption {
      description = "Default search engine";
      default = config.custom.search.engines.kagi;
      example = config.custom.search.engines.google;
      type = options.custom.search.engines.type.nestedTypes.elemType;
    };
  };

  config = mkIf cfg.enable {};
}
