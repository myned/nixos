{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.mangohud;
in {
  options.custom.programs.mangohud = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://github.com/flightlessmango/MangoHud
        programs.mangohud = {
          enable = true;
          enableSessionWide = true;

          settings = {
            background_alpha = 0;
            background_color = "002b36";
            battery = true;
            battery_watt = true;
            core_load = true;
            cpu_color = "268bd2";
            cpu_temp = true;
            device_battery = "gamepad,mouse";
            dynamic_frame_timing = true;
            engine_color = "dc322f";
            font_file = "${pkgs.nerd-fonts.iosevka}/share/fonts/truetype/NerdFonts/Iosevka/IosevkaNerdFontPropo-SemiBold.ttf";
            font_size = 24;
            fps_limit = "100,75,60,50"; # !! Monitor dependent
            fps_limit_method = "early"; # Smoother frametimes compared to late
            frametime = true;
            frametime_color = "859900";
            #// gl_vsync = -1; # Adaptive
            gpu_color = "2aa198";
            gpu_load_change = true;
            gpu_temp = true;
            gpu_stats = true;
            hud_compact = true;
            io_color = "b58900";
            io_read = true;
            io_write = true;
            no_display = true; # Hide by default
            position = "top-center";
            ram = true;
            ram_color = "d33682";
            reload_cfg = "Control_L+Shift_L+slash";
            show_fps_limit = true;
            swap = true;
            text_color = "fdf6e3";
            throttling_status_graph = true;
            toggle_fps_limit = "Control_L+period";
            toggle_hud = "Control_L+slash";
            #// vsync = 0; # Adaptive
            vram = true;
            vram_color = "6c71c4";
          };
        };

        # TODO: Use stylix
        # https://stylix.danth.me/options/modules/mangohud.html
        stylix.targets.mangohud.enable = false;
      }
    ];
  };
}
