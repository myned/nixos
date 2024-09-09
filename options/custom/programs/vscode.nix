{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.programs.vscode;
in
{
  options.custom.programs.vscode.enable = mkOption { default = false; };

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/VSCodium
    # https://github.com/VSCodium/vscodium
    #!! Configuration is imperative
    programs.vscode = {
      enable = true;
      mutableExtensionsDir = false;
      package = pkgs.vscodium;

      # https://github.com/nix-community/nix-vscode-extensions
      #?? nixos-rebuild repl > inputs.nix-vscode-extensions.extensions.${pkgs.system}.*
      extensions = with inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
        # Some extensions go missing from open-vsx, so use official marketplace
        # https://github.com/nix-community/nix-vscode-extensions?tab=readme-ov-file#note
        aaron-bond.better-comments
        antfu.iconify
        antfu.unocss
        bedsteler20.gnome-magic
        bilelmoussaoui.flatpak-vscode
        bmalehorn.vscode-fish
        bmewburn.vscode-intelephense-client
        bodil.blueprint-gtk
        bradlc.vscode-tailwindcss
        cormoran.disable-default-keybinding
        csstools.postcss
        dbaeumer.vscode-eslint
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
        ms-python.python
        natizyskunk.sftp
        pkief.material-icon-theme
        pkief.material-product-icons
        sirmspencer.vscode-autohide
        sketchbuch.vsc-workspace-sidebar
        svelte.svelte-vscode
        timonwong.shellcheck
        vincaslt.highlight-matching-tag
      ];
    };

    home = {
      # Extension dependencies
      packages = with pkgs; [
        blueprint-compiler # blueprint-gtk
        nixd # nix-ide
        nixfmt-rfc-style # nix-ide
        shfmt # shell-format
      ];

      # https://github.com/nix-community/nixd/blob/main/nixd/docs/features.md
      sessionVariables.NIXD_FLAGS = "--inlay-hints=false"; # Disable package versions in the editor

      file = with config.home-manager.users.${config.custom.username}.lib.file; {
        # Imperative symlinks intended to be synced
        ".config/VSCodium/User/settings.json".source = mkOutOfStoreSymlink "/home/${config.custom.username}/SYNC/dev/config/vscode/settings.json";
        ".config/VSCodium/User/keybindings.json".source = mkOutOfStoreSymlink "/home/${config.custom.username}/SYNC/dev/config/vscode/keybindings.json";
        ".config/VSCodium/User/snippets/".source = mkOutOfStoreSymlink "/home/${config.custom.username}/SYNC/dev/config/vscode/snippets/";
        ".config/VSCodium/User/profiles/".source = mkOutOfStoreSymlink "/home/${config.custom.username}/SYNC/dev/config/vscode/profiles/";

        # Work around wrong wmclass
        # https://github.com/microsoft/vscode/issues/129953
        # https://github.com/VSCodium/vscodium/issues/1414
        #!! Keep updated with upstream desktop file
        #?? cat /etc/profiles/per-user/USER/share/applications/codium.desktop
        # ".local/share/applications/codium.desktop".text = ''
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
  };
}
