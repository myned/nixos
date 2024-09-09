{ config, lib, ... }:

with lib;

{
  config.custom.services = mkMerge [
    (mkIf config.custom.default {
      #// agenix.enable = true;
      tailscale.enable = true;
    })

    (mkIf config.custom.minimal {
      dbus.enable = true;
      flatpak.enable = true;
      fwupd.enable = true;
      geoclue2.enable = true;
      kdeconnect.enable = true;
      keyd.enable = true;
      libinput.enable = true;
      logind.enable = true;
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
      easyeffects.enable = true;
      gammastep.enable = true;
      gnome-keyring.enable = true;
      gpg-agent.enable = true;
      greetd.enable = true;
      hypridle.enable = true;
      #// hyprpaper.enable = true;
      #// mako.enable = true;
      #// network-manager-applet.enable = true;
      samba.enable = true;
      #// swayidle.enable = true;
      swaync.enable = true;
      swayosd.enable = true;
      #// xembed-sni-proxy.enable = true;
    })
  ];
}
