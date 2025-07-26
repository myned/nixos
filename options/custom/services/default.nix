{
  config,
  lib,
  ...
}:
with lib; {
  config.custom.services = mkMerge [
    (mkIf config.custom.default {
      automatic-timezoned.enable = true;
      fail2ban.enable = true;
      geoclue2.enable = true;
      glances.enable = true;
      #// kmscon.enable = true;
      #// netbird.enable = true;
      #// postfix.enable = true;
      smartd.enable = !config.custom.vm;
      sshd.enable = true;
      tailscale.enable = true;
      #// tzupdate.enable = true;
    })

    (mkIf config.custom.minimal {
      dbus.enable = true;
      flatpak.enable = true;
      fwupd.enable = true;
      libinput.enable = true;
      openrazer.enable = true;
      pipewire.enable = true;
      playerctld.enable = true;
      ratbagd.enable = true;
      syncthing.enable = true;
      udev.enable = true;
      upower.enable = true;
    })

    (mkIf config.custom.full {
      #// avizo.enable = true;
      #// blueman-applet.enable = true;
      #// clipcat.enable = true;
      #// cliphist.enable = true;
      #// clipmenu.enable = true;
      easyeffects.enable = true;
      gammastep.enable = true;
      gnome-keyring.enable = true;
      gpg-agent.enable = true;
      greetd.enable = true;
      hypridle.enable = true;
      #// hyprpaper.enable = true;
      kdeconnect.enable = true;
      keyd.enable = true;
      #// mako.enable = true;
      mullvad.enable = true;
      #// network-manager-applet.enable = true;
      ntfy.enable = true;
      ollama.enable = true;
      samba.enable = true;
      #// swayidle.enable = true;
      swaync.enable = true;
      swayosd.enable = true;
      sysprof.enable = true;
      systemd-lock-handler.enable = true;
      usbmuxd.enable = true;
      #// wlsunset.enable = true;
      #// xembed-sni-proxy.enable = true;
      #// zerotierone.enable = true;
    })
  ];
}
