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
        bash.enable = true;
        direnv.enable = true;
        fastfetch.enable = true;
        fish.enable = true;
        git.enable = true;
        htop.enable = true;
        man.enable = true;
        nano.enable = true;
        nh.enable = true;
        nix-index.enable = true;
        polkit.enable = true;
        qalculate.enable = true;
        ssh.enable = true;
        starship.enable = true;
        sudo.enable = true;
        tmux.enable = true;
      })

      (mkIf config.custom.minimal {
        appimage.enable = true;
        dconf.enable = true;
        gamescope.enable = true;
        ghostty.enable = true;
        nautilus.enable = true;
        nvtop.enable = true;
      })

      (mkIf config.custom.full {
        discord.enable = true;
        distrobox.enable = true;
        element-desktop.enable = true;
        gamemode.enable = true;
        gpg.enable = true;
        localsend.enable = true;
        mangohud.enable = true;
        nix-ld.enable = true;
        obs-studio.enable = true;
        #// onedrive.enable = true;
        onlyoffice.enable = true;
        proton.enable = true;
        remmina.enable = true;
        seahorse.enable = true;
        steam.enable = true;
        tio.enable = true;
        vscode.enable = true;
        #// waybar.enable = true;
        wireshark.enable = true;
        #// ydotool.enable = true;
        zed.enable = true;
      })
    ];
  };
}
