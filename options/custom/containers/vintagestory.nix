{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.containers.vintagestory;
  containerCfg = config.containers.vintagestory;
  hostCfg = config;
in {
  options.custom.containers.vintagestory = {
    enable = mkEnableOption "vintagestory";

    mods = mkOption {
      description = "Attrset of mod source URLs to hashes";
      default = mapAttrs' (mod: hash: nameValuePair "https://mods.vintagestory.at/download/${mod}" hash) {
        "76988/playermodellib_1.10.11.zip" = "sha256-BvuXTOU3niZBaOUJ1k6KCw54AfMvDh5SqI1Y/2mL878="; # https://mods.vintagestory.at/playermodellib
        "77288/lupines_0.1.10.zip" = "sha256-+97hgyfr84cTBFxsZWMGGDYfi9sTd4yAoywYY9zfaa4="; # https://mods.vintagestory.at/lupines
        "77676/fluffydreg_0.6.7.zip" = "sha256-FrOJIT/yH5mgFLZL1u+zKwZxP0VCUqtgJNXemi+n0JE="; # https://mods.vintagestory.at/show/mod/32910
        "77898/koboldplayerrdx_1.3.14.zip" = "sha256-FVQUpiLf7nUYpQH0bqKOiOUp4EpPSEpgIF+7nf8UzMc="; # https://mods.vintagestory.at/koboldrdx
      };
      example = {
        "https://mods.vintagestory.at/download/76988/playermodellib_1.10.11.zip" = "sha256-BvuXTOU3niZBaOUJ1k6KCw54AfMvDh5SqI1Y/2mL878=";
      };
      type = with types; nullOr attrs;
    };
  };

  config = mkIf cfg.enable {
    containers.vintagestory = {
      agenix.secrets = optionals containerCfg.agenix.enable [
        "${hostCfg.custom.hostname}/vintagestory/serverconfig.json"
      ];

      bindMounts = {
        # Mount dataDir to server state directory
        # https://github.com/PierreBorine/vintagestory-nix/blob/5f8336470092f6ffbaf60e9db793c810a1e68e47/module/default.nix#L72
        "/var/lib/${containerCfg.config.services.vintagestory.dataPath}:idmap" = mkIf (containerCfg.dataDir != null) {
          hostPath = containerCfg.dataDir;
          isReadOnly = false;
        };

        # https://wiki.vintagestory.at/Server_Config
        # https://wiki.vintagestory.at/World_Configuration
        "/var/lib/${containerCfg.config.services.vintagestory.dataPath}/serverconfig.json:idmap" = {
          hostPath = hostCfg.age.secrets."${hostCfg.custom.hostname}/vintagestory/serverconfig.json".path;
          isReadOnly = true;
        };
      };

      forwardPorts = [
        {
          hostPort = containerCfg.config.services.vintagestory.port;
          protocol = "tcp";
        }
        {
          hostPort = containerCfg.config.services.vintagestory.port;
          protocol = "udp";
        }
      ];

      config = {pkgs, ...}: {
        # https://github.com/PierreBorine/vintagestory-nix
        imports = [inputs.vintagestory-nix.nixosModules.default];
        nixpkgs.overlays = [inputs.vintagestory-nix.overlays.default];
        nixpkgs.config.allowUnfree = true;

        # https://github.com/PierreBorine/vintagestory-nix/blob/master/module/default.nix
        # https://wiki.vintagestory.at/Guide:Dedicated_Server
        services.vintagestory = {
          enable = true;
          package = pkgs.vintagestoryPackages.v1-21-6;
          dataPath = "vintagestory"; # /var/lib/vintagestory
          port = 42420; # TCP/UDP
          openFirewall = true;

          # TODO: Consider vs2nix packages
          # https://github.com/dtomvan/vs2nix
          # https://mods.vintagestory.at/
          extraFlags = let
            mods = toString (pkgs.linkFarmFromDrvs "Mods" (mapAttrsToList (url: hash: pkgs.fetchurl {inherit url hash;}) cfg.mods));
          in
            mkIf (cfg.mods != null) ["--addModPath" mods];
        };

        # HACK: Ensure state directory is created before service starts
        systemd.tmpfiles.settings.vintagestory = {
          "/var/lib/${containerCfg.config.services.vintagestory.dataPath}".d = {
            mode = "0775"; # -rwxrwxr-x
            user = "vintagestory";
            group = "vintagestory";
          };
        };
      };
    };

    age.secrets."${hostCfg.custom.hostname}/vintagestory/serverconfig.json" = {
      owner = "997"; # vintagestory
      group = "996"; # vintagestory
    };
  };
}
