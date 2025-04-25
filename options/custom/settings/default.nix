{
  config,
  lib,
  ...
}:
with lib; {
  config.custom.settings = mkMerge [
    (mkIf config.custom.default {
      boot.enable = true;
      environment.enable = true;
      hardware.enable = true;
      networking.enable = true;
      packages.enable = true;
      users.enable = true;
    })

    (mkIf config.custom.minimal {
      dconf.enable = true;
      fonts.enable = true;
      #// gtk.enable = true;
      #// icons.enable = true;
      #// qt.enable = true;
      stylix.enable = true;
      xdg.enable = true;
    })

    (mkIf config.custom.full {
      accounts.enable = true;
      storage.enable = true;
      vm.enable = true;
      waydroid.enable = true;
    })
  ];
}
