{
  config,
  lib,
  ...
}:
with lib; {
  config.custom.programs = mkMerge [
    (mkIf config.custom.default {
      bash.enable = true;
      direnv.enable = true;
      fastfetch.enable = true;
      fish.enable = true;
      git.enable = true;
      htop.enable = true;
      man.enable = true;
      mosh.enable = true;
      nano.enable = true;
      nh.enable = true;
      nix-index.enable = true;
      nushell.enable = true;
      polkit.enable = true;
      ssh.enable = true;
      starship.enable = true;
      sudo.enable = true;
      tmux.enable = true;
    })

    (mkIf config.custom.minimal {
      #// alacritty.enable = true;
      appimage.enable = true;
      chromium.enable = true;
      dconf.enable = true;
      firefox.enable = true;
      #// foot.enable = true;
      #// gnome-terminal.enable = true;
      #// kdeconnect.enable = true;
      kitty.enable = true;
      nautilus.enable = true;
      nvtop.enable = true;
      #// wezterm.enable = true;
    })

    (mkIf config.custom.full {
      _1password.enable = true;
      adb.enable = true;
      #// ags.enable = true;
      #// anyrun.enable = true;
      #// bitwarden-menu.enable = true;
      #// clipse.enable = true;
      discord.enable = true;
      element-desktop.enable = true;
      #// fuzzel.enable = true;
      gamemode.enable = true;
      gamescope.enable = true;
      #// gnome-shell.enable = true;
      gpg.enable = true;
      #// gtklock.enable = true;
      hyprlock.enable = true;
      libreoffice.enable = true;
      #// librewolf.enable = true;
      localsend.enable = true;
      logseq.enable = true;
      mangohud.enable = true;
      networkmanager-dmenu.enable = true;
      #// nheko.enable = true;
      nix-ld.enable = true;
      obs-studio.enable = true;
      onlyoffice.enable = true;
      #// onedrive.enable = true;
      #// path-of-building.enable = true;
      #// rbw.enable = true;
      remmina.enable = true;
      #// rofi-rbw.enable = true;
      #// rofi.enable = true;
      seahorse.enable = true;
      #// slurp.enable = true;
      steam.enable = true;
      #// swaylock.enable = true;
      #// thunderbird.enable = true;
      tio.enable = true;
      vscode.enable = true;
      walker.enable = true;
      waybar.enable = true;
      wireshark.enable = true;
      #// wofi.enable = true;
      #// wpaperd.enable = true;
    })
  ];
}
