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

  config = mkIf cfg.enable {
    custom.services = mkMerge [
      (mkIf config.custom.default {
        #// earlyoom.enable = mkDefault true;
        fail2ban.enable = mkDefault true;
        #// glances.enable = mkDefault true;
        #// postfix.enable = mkDefault true;

        # TODO: Figure out hardware conditions (error on boot w/o compatible disk)
        #// smartd.enable = mkDefault true;

        sshd.enable = mkDefault true;
        tailscale.enable = mkDefault true;
      })

      (mkIf config.custom.minimal {
        dbus.enable = mkDefault true;
        flatpak.enable = mkDefault true;
        fwupd.enable = mkDefault true;
        geoclue2.enable = mkDefault true;
        #// kmscon.enable = mkDefault true;
        libinput.enable = mkDefault true;
        logind.enable = mkDefault true;
        pipewire.enable = mkDefault true;
        #// playerctld.enable = mkDefault true;
        syncthing.enable = mkDefault true;
        udev.enable = mkDefault true;
        upower.enable = mkDefault true;
      })

      (mkIf config.custom.full {
        avahi.enable = mkDefault true;
        #// blueman.enable = mkDefault true;
        displaylink.enable = mkDefault true;
        easyeffects.enable = mkDefault true;

        # BUG: Prevents activation of /usr, causing systemd to halt after installation or with Impermanence
        # https://github.com/NixOS/nixpkgs/issues/375376
        #// envfs.enable = mkDefault true;

        gammastep.enable = mkDefault true;
        #// gdm.enable = mkDefault true;
        gnome-keyring.enable = mkDefault true;
        #// gpg-agent.enable = mkDefault true;
        #// greetd.enable = mkDefault true;
        #// kdeconnect.enable = mkDefault true;
        keyd.enable = mkDefault true;
        #// ntfy.enable = mkDefault true;
        #// ollama.enable = mkDefault true;
        #// openrazer.enable = mkDefault true;
        printing.enable = mkDefault true;
        ratbagd.enable = mkDefault true;
        #// samba.enable = mkDefault true;
        #// swaync.enable = mkDefault true;
        #// swayosd.enable = mkDefault true;
        #// sysprof.enable = mkDefault true;
        usbmuxd.enable = mkDefault true;
      })
    ];
  };
}
