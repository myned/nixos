{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.settings.nixgl;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.settings.nixgl = {
    enable = mkOption {default = false;};

    wrapper = mkOption {
      default =
        if with config.custom.settings.hardware.dgpu; driver == "nvidia" || driver == "nouveau"
        then "nvidia"
        else "mesa";

      type = types.enum ["mesa" "nvidia"];
    };

    offload = mkOption {
      default = "${cfg.wrapper}Prime";
      type = types.enum ["mesaPrime" "nvidiaPrime"];
    };
  };

  config = mkIf cfg.enable {
    # https://github.com/nix-community/home-manager/blob/master/modules/misc/nixgl.nix
    #?? nixgl[-offload] <program>
    environment.shellAliases = let
      wrapper =
        if cfg.wrapper == "nvidia"
        then "nixGLNvidia"
        else "nixGLMesa";

      offload =
        if cfg.offload == "nvidiaPrime"
        then "nixGLNvidiaPrime"
        else "nixGLMesaPrime";
    in {
      nixgl = wrapper;
      nixgl-offload = offload;
    };

    # HACK: Flutter needs to be wrapped for GPU offloading
    #?? <package> = hm.lib.nixGL.wrap prev.<package>;
    nixpkgs.overlays = [
      (final: prev: {
        keyguard = hm.lib.nixGL.wrap prev.keyguard;
        rustdesk-flutter = hm.lib.nixGL.wrap prev.rustdesk-flutter;
      })
    ];

    home-manager.sharedModules = [
      {
        # https://github.com/nix-community/nixGL
        # https://github.com/nix-community/nixGL/issues/114
        # https://nix-community.github.io/home-manager/index.xhtml#sec-usage-gpu-non-nixos
        nixGL = {
          vulkan.enable = true;
          packages = pkgs.nixgl; # Overlay
          defaultWrapper = cfg.wrapper;
          offloadWrapper = cfg.offload;
          installScripts = [cfg.wrapper cfg.offload];
        };
      }
    ];
  };
}
