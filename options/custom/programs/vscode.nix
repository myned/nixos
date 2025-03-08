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

  config = {
    # https://github.com/nix-community/nix-vscode-extensions
    nixpkgs.overlays = [inputs.nix-vscode-extensions.overlays.default];

    environment = {
      sessionVariables = {
        # https://github.com/nix-community/nixd/blob/main/nixd/docs/features.md
        NIXD_FLAGS = "--inlay-hints=false"; # Disable package versions in the editor
      };

      # Extension dependencies
      systemPackages = with pkgs; [
        alejandra # nix-ide
        blueprint-compiler # blueprint-gtk
        caddy # caddyfile-support
        nixd # nix-ide
        powershell # powershell
        shfmt # shell-format
      ];
    };

    home-manager.sharedModules = mkIf cfg.enable [
      {
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
                antfu.iconify
                antfu.unocss
                bedsteler20.gnome-magic
                bilelmoussaoui.flatpak-vscode
                bmalehorn.vscode-fish
                bmewburn.vscode-intelephense-client
                bradlc.vscode-tailwindcss
                csstools.postcss
                dbaeumer.vscode-eslint
                detachhead.basedpyright
                #// eamodio.gitlens
                esbenp.prettier-vscode
                foxundermoon.shell-format
                #// ginfuru.ginfuru-better-solarized-dark-theme
                gruntfuggly.todo-tree
                jnoortheen.nix-ide
                koihik.vscode-lua-format
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
                svelte.svelte-vscode
                timonwong.shellcheck
                vincaslt.highlight-matching-tag
              ]
              ++ (with pkgs.vscode-marketplace; [
                #!! Some extensions go missing from open-vsx, so use official marketplace as fallback
                # https://github.com/nix-community/nix-vscode-extensions?tab=readme-ov-file#note
                bodil.blueprint-gtk
                cormoran.disable-default-keybinding
                ms-python.python
                sirmspencer.vscode-autohide
              ]);
          };
        };

        xdg.configFile = with hm.lib.file; {
          # Imperative symlinks intended to be synced
          "VSCodium/User/settings.json" = {
            force = true;
            source = mkOutOfStoreSymlink "${config.custom.sync}/dev/config/vscode/settings.json";
          };

          "VSCodium/User/keybindings.json" = {
            force = true;
            source = mkOutOfStoreSymlink "${config.custom.sync}/dev/config/vscode/keybindings.json";
          };

          "VSCodium/User/snippets/" = {
            force = true;
            source = mkOutOfStoreSymlink "${config.custom.sync}/dev/config/vscode/snippets/";
          };

          "VSCodium/User/profiles/" = {
            force = true;
            source = mkOutOfStoreSymlink "${config.custom.sync}/dev/config/vscode/profiles/";
          };
        };
      }
    ];
  };
}
