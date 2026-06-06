{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.vscode;
  hm = config.home-manager.users.${config.custom.username};
in {
  options.custom.programs.vscode = {
    enable = mkEnableOption "vscode";
  };

  config = mkIf cfg.enable {
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

    home-manager.sharedModules = [
      {
        # https://wiki.nixos.org/wiki/VSCodium
        # https://github.com/VSCodium/vscodium
        #!! Configuration is imperative
        programs.vscode = {
          enable = true;
          #// mutableExtensionsDir = false;
          #// package = pkgs.vscodium;
        };

        # TODO: Use stylix
        # https://nix-community.github.io/stylix/options/modules/vscode.html
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
            source = hm.lib.file.mkOutOfStoreSymlink "${config.custom.syncDir}/${source}";
            force = true;
          };
        in {
          #!! Imperative synced files
          "Code/User/keybindings.json" = sync "dev/config/vscode/keybindings.json";
          "Code/User/profiles/" = sync "dev/config/vscode/profiles/";
          "Code/User/settings.json" = sync "dev/config/vscode/settings.json";
          "Code/User/snippets/" = sync "dev/config/vscode/snippets/";

          "VSCodium/User/keybindings.json" = sync "dev/config/vscode/keybindings.json";
          "VSCodium/User/profiles/" = sync "dev/config/vscode/profiles/";
          "VSCodium/User/settings.json" = sync "dev/config/vscode/settings.json";
          "VSCodium/User/snippets/" = sync "dev/config/vscode/snippets/";
        };
      }
    ];
  };
}
