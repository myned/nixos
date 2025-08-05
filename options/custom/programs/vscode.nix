{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.vscode;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.vscode = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://github.com/nix-community/nix-vscode-extensions
    nixpkgs.overlays = [inputs.nix-vscode-extensions.overlays.default];

    # Extension dependencies
    environment.systemPackages = with pkgs; [
      alejandra # nix-ide
      blueprint-compiler # blueprint-gtk
      caddy # caddyfile-support
      nil # nix-ide
      nixd # nix-ide
      powershell # powershell
      shellcheck # shellcheck
      shfmt # shell-format
    ];

    home-manager.users.${config.custom.username} = {
      # https://wiki.nixos.org/wiki/VSCodium
      # https://github.com/VSCodium/vscodium
      #!! Configuration is imperative
      programs.vscode = {
        enable = true;
        mutableExtensionsDir = false;
        package = pkgs.vscodium;

        profiles.default = {
          #?? nixos-rebuild repl > pkgs.REPO.*
          extensions = with pkgs.open-vsx;
            [
              aaron-bond.better-comments
              #// antfu.iconify
              #// antfu.unocss
              #// bedsteler20.gnome-magic
              #// bilelmoussaoui.flatpak-vscode
              bmalehorn.vscode-fish
              #// bmewburn.vscode-intelephense-client
              bradlc.vscode-tailwindcss
              #// csstools.postcss
              dbaeumer.vscode-eslint
              detachhead.basedpyright
              #// eamodio.gitlens
              esbenp.prettier-vscode
              foxundermoon.shell-format
              #// ginfuru.ginfuru-better-solarized-dark-theme
              gruntfuggly.todo-tree
              jnoortheen.nix-ide
              #// koihik.vscode-lua-format
              matthewpi.caddyfile-support
              mhutchie.git-graph
              mkhl.direnv
              ms-python.black-formatter
              ms-python.debugpy
              ms-python.isort
              ms-vscode.powershell
              natizyskunk.sftp
              pkief.material-icon-theme
              pkief.material-product-icons
              sketchbuch.vsc-workspace-sidebar
              #// svelte.svelte-vscode
              timonwong.shellcheck
              vincaslt.highlight-matching-tag
            ]
            ++ (with pkgs.vscode-marketplace; [
              #!! Some extensions go missing from open-vsx, so use official marketplace as fallback
              # https://github.com/nix-community/nix-vscode-extensions?tab=readme-ov-file#note
              #// bodil.blueprint-gtk
              cormoran.disable-default-keybinding
              ms-python.python
              sirmspencer.vscode-autohide
            ]);
        };
      };

      # TODO: Use stylix
      # https://stylix.danth.me/options/modules/vscode.html
      stylix.targets.vscode = {
        enable = false;
        profileNames = ["default"];
      };

      home.sessionVariables = {
        # https://github.com/nix-community/nixd/blob/main/nixd/docs/features.md
        NIXD_FLAGS = "--inlay-hints=false"; # Disable package versions in the editor
      };

      xdg.configFile = let
        sync = source: {
          source = hm.lib.file.mkOutOfStoreSymlink "${config.custom.sync}/${source}";
          force = true;
        };
      in {
        #!! Imperative synced files
        "VSCodium/User/keybindings.json" = sync "dev/config/vscode/keybindings.json";
        "VSCodium/User/profiles/" = sync "dev/config/vscode/profiles/";
        "VSCodium/User/settings.json" = sync "dev/config/vscode/settings.json";
        "VSCodium/User/snippets/" = sync "dev/config/vscode/snippets/";
      };
    };
  };
}
