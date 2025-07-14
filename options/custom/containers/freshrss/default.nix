{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.freshrss;
in {
  options.custom.containers.freshrss = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    #?? arion-freshrss pull
    environment.shellAliases.arion-freshrss = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.freshrss.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.freshrss.settings.services = {
      # https://github.com/FreshRSS/FreshRSS
      # https://github.com/FreshRSS/FreshRSS/tree/edge/Docker
      freshrss.service = {
        container_name = "freshrss";
        image = "freshrss/freshrss:latest"; # https://hub.docker.com/r/freshrss/freshrss/tags
        ports = ["8088:80/tcp"];
        restart = "unless-stopped";

        environment = {
          TRUSTED_PROXY = "172.16.0.0/12";
        };

        volumes = let
          #?? (extension "NAME" SOURCE)
          extension = name: source: "${source}:/var/www/FreshRSS/extensions/${name}";
        in [
          "${config.custom.containers.directory}/freshrss/data:/var/www/FreshRSS/data"

          # Themes
          # https://github.com/FreshRSS/FreshRSS/tree/edge/p/themes/base-theme
          "${./themes/Solarized}:/var/www/FreshRSS/p/themes/Solarized"

          # Extensions
          # https://github.com/FreshRSS/Extensions
          #!! Causes docker permission changes to fail on container start due to immutable source
          (extension "autorefresh" "${inputs.freshrss-autorefresh}/xExtension-AutoRefresh") # https://github.com/Eisa01/FreshRSS---Auto-Refresh-Extension
          (extension "clickablelinks" "${inputs.freshrss-kapdap}/xExtension-ClickableLinks") # https://github.com/kapdap/freshrss-extensions/tree/master/xExtension-ClickableLinks
          (extension "colorfullist" "${inputs.freshrss-extensions}/xExtension-ColorfulList") # https://github.com/FreshRSS/Extensions/tree/master/xExtension-ColorfulList
          (extension "comicsinfeed" inputs.freshrss-comicsinfeed) # https://github.com/giventofly/freshrss-comicsinfeed
          (extension "dateformat" inputs.freshrss-dateformat) # https://github.com/aledeg/xExtension-DateFormat
          (extension "filtertitle" "${inputs.freshrss-cntools}/xExtension-FilterTitle") # https://github.com/cn-tools/cntools_FreshRssExtensions/tree/master/xExtension-FilterTitle
          (extension "kagisummarizer" inputs.freshrss-kagisummarizer) # https://code.sitosis.com/rudism/freshrss-kagi-summarizer
          (extension "markpreviousasread" inputs.freshrss-markpreviousasread) # https://github.com/kalvn/freshrss-mark-previous-as-read
          (extension "quickcollapse" "${inputs.freshrss-extensions}/xExtension-QuickCollapse") # https://github.com/FreshRSS/Extensions/tree/master/xExtension-QuickCollapse
          (extension "readingtime" "${inputs.freshrss-extensions}/xExtension-ReadingTime") # https://github.com/FreshRSS/Extensions/tree/master/xExtension-ReadingTime
          (extension "removeemojis" "${inputs.freshrss-cntools}/xExtension-RemoveEmojis") # https://github.com/cn-tools/cntools_FreshRssExtensions/tree/master/xExtension-RemoveEmojis
          (extension "youtube" "${inputs.freshrss-extensions}/xExtension-YouTube") # https://github.com/FreshRSS/Extensions/tree/master/xExtension-YouTube
        ];
      };
    };
  };
}
