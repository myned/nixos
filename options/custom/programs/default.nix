{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs;
in {
  options.custom.programs = {
    enable = mkEnableOption "programs";
  };

  config = mkIf cfg.enable {
    custom.programs = mkMerge [
      (mkIf config.custom.default {
        bash.enable = mkDefault true;
        direnv.enable = mkDefault true;
        fastfetch.enable = mkDefault true;
        fish.enable = mkDefault true;
        git.enable = mkDefault true;
        htop.enable = mkDefault true;
        man.enable = mkDefault true;
        nano.enable = mkDefault true;
        nh.enable = mkDefault true;
        nix-index.enable = mkDefault true;
        polkit.enable = mkDefault true;
        qalculate.enable = mkDefault true;
        ssh.enable = mkDefault true;
        starship.enable = mkDefault true;
        sudo.enable = mkDefault true;
        tmux.enable = mkDefault true;
      })

      (mkIf config.custom.minimal {
        appimage.enable = mkDefault true;
        dconf.enable = mkDefault true;
        gamescope.enable = mkDefault true;
        ghostty.enable = mkDefault true;
        nautilus.enable = mkDefault true;
        nvtop.enable = mkDefault true;
      })

      (mkIf config.custom.full {
        discord.enable = mkDefault true;
        distrobox.enable = mkDefault true;
        element-desktop.enable = mkDefault true;
        gamemode.enable = mkDefault true;
        gpg.enable = mkDefault true;
        localsend.enable = mkDefault true;
        mangohud.enable = mkDefault true;
        nix-ld.enable = mkDefault true;
        obs-studio.enable = mkDefault true;
        #// onedrive.enable = mkDefault true;
        onlyoffice.enable = mkDefault true;
        proton.enable = mkDefault true;
        remmina.enable = mkDefault true;
        seahorse.enable = mkDefault true;
        steam.enable = mkDefault true;
        tio.enable = mkDefault true;
        vscode.enable = mkDefault true;
        #// waybar.enable = mkDefault true;
        wireshark.enable = mkDefault true;
        #// ydotool.enable = mkDefault true;
        zed.enable = mkDefault true;
      })
    ];
  };
}
