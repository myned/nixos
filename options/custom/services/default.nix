{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.services;
in {
  options.custom.services = {
    enable = mkEnableOption "services";
  };

  config.custom.services = mkMerge [
    (mkIf config.custom.default {
      automatic-timezoned.enable = true;
      #// earlyoom.enable = true;
      fail2ban.enable = true;
      geoclue2.enable = true;
      #// glances.enable = true;
      #// postfix.enable = true;

      # TODO: Figure out hardware conditions (error on boot w/o compatible disk)
      #// smartd.enable = true;

      sshd.enable = true;
      tailscale.enable = true;
    })

    (mkIf config.custom.minimal {
      dbus.enable = true;
      flatpak.enable = true;
      fwupd.enable = true;
      #// kmscon.enable = true;
      libinput.enable = true;
      logind.enable = true;
      pipewire.enable = true;
      playerctld.enable = true;
      syncthing.enable = true;
      udev.enable = true;
      upower.enable = true;
    })

    (mkIf config.custom.full {
      avahi.enable = true;
      #// blueman.enable = true;
      displaylink.enable = true;
      easyeffects.enable = true;

      # BUG: Prevents activation of /usr, causing systemd to halt after installation or with Impermanence
      # https://github.com/NixOS/nixpkgs/issues/375376
      #// envfs.enable = true;

      gammastep.enable = true;
      #// gdm.enable = true;
      gnome-keyring.enable = true;
      gpg-agent.enable = true;
      #// greetd.enable = true;
      kdeconnect.enable = true;
      keyd.enable = true;
      ntfy.enable = true;
      ollama.enable = true;
      #// openrazer.enable = true;
      printing.enable = true;
      ratbagd.enable = true;
      samba.enable = true;
      #// swaync.enable = true;
      #// swayosd.enable = true;
      sysprof.enable = true;
      usbmuxd.enable = true;
    })
  ];
}
