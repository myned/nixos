{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.settings.waydroid;
in {
  options.custom.settings.waydroid.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/WayDroid
    # https://wiki.archlinux.org/title/Waydroid
    #!! Configuration is imperative
    # Optionally update image
    #?? sudo waydroid upgrade

    # Install image
    #?? sudo waydroid init --system_type <FOSS|GAPPS>

    # Optional helper script
    # https://github.com/casualsnek/waydroid_script
    #?? git clone https://github.com/casualsnek/waydroid_script.git
    #?? cd waydroid_script
    #?? python -m venv .venv
    #?? source .venv/bin/activate.fish
    #?? pip install -r requirements.txt
    #?? sudo python main.py install microg
    #?? sudo python main.py install libndk
    #?? sudo python main.py hack hidestatusbar

    # Start session
    #?? waydroid session start &

    # Optionally certify with Google for the Play Store
    #?? sudo waydroid shell
    #?? ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"
    #?? https://www.google.com/android/uncertified

    # Enable windowed applications
    #?? waydroid prop set persist.waydroid.multi_windows true

    # Set window size
    #?? waydroid prop set persist.waydroid.width WIDTH
    #?? waydroid prop set persist.waydroid.height HEIGHT
    #?? sudo waydroid shell
    #?? wm size reset

    # Optionally, run waydroid on the same GPU as the compositor
    # https://wiki.archlinux.org/title/Waydroid#Graphical_Corruption_on_multi-gpu_systems
    # https://github.com/Quackdoc/waydroid-scripts/blob/main/waydroid-choose-gpu.sh
    #!! Rerun after each waydroid_script invocation
    #?? sudo sed -i 's|/dev/dri/card0|/dev/dri/card1|' /var/lib/waydroid/lxc/waydroid/config_nodes
    #?? sudo sed -i 's|/dev/dri/renderD128|/dev/dri/renderD129|' /var/lib/waydroid/lxc/waydroid/config_nodes

    # Some games like Arknights do not use the proper storage mechanism and need insecure permissions
    # https://github.com/casualsnek/waydroid_script?tab=readme-ov-file#granting-full-permission-for-apps-data-hack
    #?? sudo waydroid shell
    #?? chmod 777 -R /sdcard/Android
    #?? chmod 777 -R /data/media/0/Android
    #?? chmod 777 -R /sdcard/Android/data
    #?? chmod 777 -R /data/media/0/Android/obb
    #?? chmod 777 -R /mnt/*/*/*/*/Android/data
    #?? chmod 777 -R /mnt/*/*/*/*/Android/obb

    # Optionally, disable unnecessary desktop files
    #?? sed -i 's|(\[Desktop Entry\])|$1\nNoDisplay=true|' ~/.local/share/applications/waydroid.*.desktop

    virtualisation.waydroid.enable = true;
  };
}
