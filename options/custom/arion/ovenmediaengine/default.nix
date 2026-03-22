{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.arion.ovenmediaengine;
in {
  options.custom.arion.ovenmediaengine = {
    enable = mkEnableOption "ovenmediaengine";
  };

  config = mkIf cfg.enable {
    #?? arion-ovenmediaengine pull
    environment.shellAliases.arion-ovenmediaengine = "sudo arion --prebuilt-file ${config.virtualisation.arion.projects.ovenmediaengine.settings.out.dockerComposeYaml}";

    virtualisation.arion.projects.ovenmediaengine.settings.services = {
      # https://github.com/AirenSoft/OvenMediaEngine
      # https://docs.ovenmediaengine.com/getting-started/getting-started-with-docker
      ovenmediaengine.service = {
        container_name = "ovenmediaengine";
        env_file = [config.age.secrets."${config.custom.hostname}/ovenmediaengine/.env".path];
        image = "airensoft/ovenmediaengine:v0.20.0"; # https://hub.docker.com/r/airensoft/ovenmediaengine/tags
        restart = "unless-stopped";
        network_mode = "host"; # https://docs.ovenmediaengine.com/getting-started#ports-used-by-default

        volumes = [
          # https://docs.ovenmediaengine.com/configuration
          # https://github.com/AirenSoft/OvenMediaEngine/blob/master/misc/conf_examples/Server.xml
          "${./Server.xml}:/opt/ovenmediaengine/bin/origin_conf/Server.xml:ro"
        ];
      };
    };

    # https://github.com/OvenMediaLabs/OvenMediaEngine/blob/master/misc/signed_policy_url_generator.sh
    environment.systemPackages = let
      #?? ome-generate <url>
      ome-generate = pkgs.writeShellApplication {
        name = "ome-generate";
        runtimeInputs = with pkgs; [coreutils openssl python3 xxd];
        text = ''
          # shellcheck disable=1091
          source ${config.age.secrets."${config.custom.hostname}/ovenmediaengine/.env".path}

          url="''${1:-}"
          test -n "$url" || exit 1

          bash ${inputs.ovenmediaengine}/misc/simple_signed_policy_url_generator.sh \
            "$OME_SECRET_KEY" \
            "$url" \
            signature \
            policy \
            "$(( 365 * 24 * 60 * 60 ))" # 1 year in seconds
        '';
      };
    in [ome-generate];

    age.secrets =
      mapAttrs (name: value: recursiveUpdate {file = "${inputs.self}/secrets/${name}";} value)
      {
        "${config.custom.hostname}/ovenmediaengine/.env" = {};
      };
  };
}
