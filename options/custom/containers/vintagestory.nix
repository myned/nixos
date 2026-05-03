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

    # TODO: Migrate to flake.nix for source control
    mods = mkOption {
      description = "Attrset of mod source URLs to hashes";
      default = {
        #?? nix hash convert --hash-algo sha256 $(nix-prefetch-url <url>)
        "https://mods.vintagestory.at/download/86351/fluffydreg_0.7.0.zip" = "sha256-hCgfihcKSYcSzEoUvaMQIMY65b7pTc/Db+af+tb2OKU="; # https://mods.vintagestory.at/show/mod/32910
        "https://mods.vintagestory.at/download/87782/wolpsocks-1.2.0.zip" = "sha256-rcd4UGaKxf+l8e4Sy7XG/OZxkXzFEJPDERKcyWL4hFc="; # https://mods.vintagestory.at/wolpsocks
        "https://mods.vintagestory.at/download/88069/StoneQuarryRepacked.3.6.2.zip" = "sha256-LRelM7g+oZSAXlpwqUnT6blMPRqkLIRYQ1DCECucmDc="; # https://mods.vintagestory.at/stonequarystandalonerepack
        "https://mods.vintagestory.at/download/88539/koboldplayerrdx_1.4.1.zip" = "sha256-6NIe1tdJ/wK7oQBnuGIFDv840j0P2rmifvSUQfMjyOA="; # https://mods.vintagestory.at/koboldrdx
        "https://mods.vintagestory.at/download/88971/playermodellib_1.17.6.zip" = "sha256-9ey+XXteCSFjkwOQe0HEHbPOTSi0rnhh40zbHmSK4Ps="; # https://mods.vintagestory.at/playermodellib
        "https://mods.vintagestory.at/download/89058/lupines_0.2.2.zip" = "sha256-jbu3sZo9kRPLPq5y9zNdY26Q5kzyxD5499mppOue2YY="; # https://mods.vintagestory.at/lupines
      };
      example = {
        "https://mods.vintagestory.at/download/76988/playermodellib_1.10.11.zip" = "sha256-BvuXTOU3niZBaOUJ1k6KCw54AfMvDh5SqI1Y/2mL878=";
      };
      type = with types; nullOr attrs;
    };
  };

  config = mkIf cfg.enable {
    containers.vintagestory = {
      bindMounts = {
        # Mount dataDir to server state directory
        # https://github.com/PierreBorine/vintagestory-nix/blob/5f8336470092f6ffbaf60e9db793c810a1e68e47/module/default.nix#L72
        "/var/lib/${containerCfg.config.services.vintagestory.dataPath}:idmap" = mkIf (containerCfg.dataDir != null) {
          hostPath = containerCfg.dataDir;
          isReadOnly = false;
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
        # https://wiki.vintagestory.at/Server_Config
        # https://wiki.vintagestory.at/World_Configuration
        #!! Imperative configuration
        services.vintagestory = {
          enable = true;

          # BUG: pkgs.vintagestoryPackages overlay eval error with stable nixpkgs
          package = inputs.vintagestory-nix.packages.${pkgs.system}.v1-22-0;

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
        systemd.tmpfiles.settings.vintagestory = let
          settings = {
            mode = "0755"; # -rwxr-xr-x
            user = "vintagestory";
            group = "vintagestory";
          };
        in {
          "/var/lib/${containerCfg.config.services.vintagestory.dataPath}" = {
            d = settings;
            Z = settings; #!! Recursive
          };
        };
      };
    };
  };
}
