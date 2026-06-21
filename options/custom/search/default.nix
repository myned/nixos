{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.search;
in {
  options.custom.search = let
    engineSubmodule = with types;
      submodule ({name, ...}: {
        options = {
          name = mkOption {
            description = "Name of the search engine";
            default = name;
            example = "google";
            type = str;
          };

          title = mkOption {
            description = "Title of the search engine";
            default = "";
            example = "Google";
            type = str;
          };

          shortcut = mkOption {
            description = "Shortcut keyword of the search engine";
            default = "";
            example = "g";
            type = str;
          };

          iconUrl = mkOption {
            description = "Icon URL of the search engine";
            default = "";
            example = "https://www.gstatic.com/images/branding/searchlogo/ico/favicon.ico";
            type = str;
          };

          searchUrl = mkOption {
            description = "Search URL of the search engine";
            default = "";
            example = "https://www.google.com/search?q=%s";
            type = str;
          };

          suggestUrl = mkOption {
            description = "Suggest URL of the search engine";
            default = "";
            example = "https://www.google.com/complete/search?q=%s";
            type = str;
          };
        };
      });
  in {
    enable = mkEnableOption "search";

    default = mkOption {
      description = "Submodule of the default search engine";
      default = cfg.engines.kagi;
      example = cfg.engines.google;
      type = engineSubmodule;
    };

    engines = mkOption {
      description = "Submodules of search engines";

      example = {
        google = {
          title = "Google";
          shortcut = "g";
          iconUrl = "https://www.gstatic.com/images/branding/searchlogo/ico/favicon.ico";
          searchUrl = "https://google.com/search?q=%s";
          suggestUrl = "https://www.google.com/complete/search?q=%s";
        };
      };

      type = types.attrsOf engineSubmodule;
    };
  };
}
