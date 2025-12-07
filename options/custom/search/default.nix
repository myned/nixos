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
    enable = mkEnableOption "search";

    default = mkOption {
      description = "Default search engine";
      default = cfg.engines.kagi;
      example = cfg.engines.google;
      type = options.custom.search.engines.type.nestedTypes.elemType;
    };
  };
}
