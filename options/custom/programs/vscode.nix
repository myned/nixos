{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.vscode;
in {
  options.custom.programs.vscode.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/VSCodium
    # https://github.com/VSCodium/vscodium
    #!! Configuration is imperative
    programs.vscode = {
      enable = true;
      mutableExtensionsDir = false;

      # Extension dependencies
      # https://wiki.nixos.org/wiki/Visual_Studio_Code#Use_VS_Code_extensions_without_additional_configuration
      package = pkgs.vscodium.fhsWithPackages (ps:
        with ps; [
          alejandra # nix-ide
          blueprint-compiler # blueprint-gtk
          nixd # nix-ide
          shfmt # shell-format
        ]);

      # https://github.com/nix-community/nix-vscode-extensions
      #?? nixos-rebuild repl > inputs.nix-vscode-extensions.extensions.${pkgs.system}.*
      extensions = let
        # Use configured version of vscode
        # https://github.com/nix-community/nix-vscode-extensions?tab=readme-ov-file#extensions
        #?? extension = with (repo "REPOSITORY"); AUTHOR.EXTENSION
        repo = repo:
          with inputs.nix-vscode-extensions.extensions.${pkgs.system};
            (forVSCodeVersion config.home-manager.users.${config.custom.username}.programs.vscode.package.version).${repo};
      in
        with (repo "open-vsx");
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
            ginfuru.ginfuru-better-solarized-dark-theme
            gruntfuggly.todo-tree
            jnoortheen.nix-ide
            koihik.vscode-lua-format
            mhutchie.git-graph
            mkhl.direnv
            ms-python.black-formatter
            ms-python.debugpy
            ms-python.isort
            natizyskunk.sftp
            pkief.material-icon-theme
            pkief.material-product-icons
            sketchbuch.vsc-workspace-sidebar
            svelte.svelte-vscode
            timonwong.shellcheck
            vincaslt.highlight-matching-tag
          ]
          ++ (with (repo "vscode-marketplace"); [
            #!! Some extensions go missing from open-vsx, so use official marketplace as fallback
            # https://github.com/nix-community/nix-vscode-extensions?tab=readme-ov-file#note
            bodil.blueprint-gtk
            cormoran.disable-default-keybinding
            ms-python.python
            sirmspencer.vscode-autohide
          ]);
    };

    xdg.configFile = with config.home-manager.users.${config.custom.username}.lib.file; {
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

    home = {
      # https://github.com/nix-community/nixd/blob/main/nixd/docs/features.md
      sessionVariables.NIXD_FLAGS = "--inlay-hints=false"; # Disable package versions in the editor

      # Work around wrong wmclass
      # https://github.com/microsoft/vscode/issues/129953
      # https://github.com/VSCodium/vscodium/issues/1414
      #!! Keep updated with upstream desktop file
      #?? cat /etc/profiles/per-user/USER/share/applications/codium.desktop
      # file.".local/share/applications/codium.desktop".text = ''
      #   [Desktop Entry]
      #   Actions=new-empty-window
      #   Categories=Utility;TextEditor;Development;IDE
      #   Comment=Code Editing. Redefined.
      #   Exec=codium %F
      #   GenericName=Text Editor
      #   Icon=vscodium
      #   Keywords=vscode
      #   MimeType=text/plain;inode/directory
      #   Name=VSCodium
      #   StartupNotify=true
      #   StartupWMClass=codium-url-handler
      #   Type=Application
      #   Version=1.4

      #   [Desktop Action new-empty-window]
      #   Exec=codium --new-window %F
      #   Icon=vscodium
      #   Name=New Empty Window
      # '';
    };
  };
}
