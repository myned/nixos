{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.bitwig-studio;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.bitwig-studio = {
    enable = mkEnableOption "bitwig-studio";
  };

  config = mkIf cfg.enable {
    # https://www.bitwig.com/
    environment.systemPackages = let
      # TODO: Override desktop file with FHS
      # HACK: Use FHS for plugin libraries
      #?? nix-alien-find-libs *.so
      bitwig-studio-fhs = pkgs.buildFHSEnv {
        name = "bitwig-studio";
        runScript = "bitwig-studio";
        targetPkgs = pkgs: [pkgs.unstable.bitwig-studio];

        profile = ''
          export LD_LIBRARY_PATH="${
            pkgs.lib.makeLibraryPath (
              with pkgs; [
                alsa-lib
                fontconfig
                freetype
                libgcc
              ]
            )
          }:$LD_LIBRARY_PATH"
        '';
      };
    in [
      bitwig-studio-fhs

      # Plugins
      #// decent-sampler # https://www.decentsamples.com/product/decent-sampler-plugin/
      #// jc303 # https://github.com/midilab/jc303
    ];

    home-manager.sharedModules = let
      sync = source: {
        source = hm.lib.file.mkOutOfStoreSymlink source;
        force = true;
      };
    in [
      {
        home.file = {
          ".BitwigStudio/prefs" = sync "${hm.home.homeDirectory}/PACK/Bitwig/Prefs";
          ".clap" = sync "${hm.home.homeDirectory}/PACK/Plugins/Linux/CLAP";
          ".vst" = sync "${hm.home.homeDirectory}/PACK/Plugins/Linux/VST";
          ".vst3" = sync "${hm.home.homeDirectory}/PACK/Plugins/Linux/VST3";
        };

        xdg.configFile = {
          "DecentSampler/Sample Libraries" = sync "${hm.home.homeDirectory}/PACK/Samples/Decent Sampler";
        };
      }
    ];
  };
}
