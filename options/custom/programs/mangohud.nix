{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.mangohud;
in {
  options.custom.programs.mangohud.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/flightlessmango/MangoHud
    programs.mangohud = {
      enable = true;
      enableSessionWide = true;

      settings = {
        background_alpha = 0;
        background_color = "002b36";
        core_load = true;
        cpu_color = "268bd2";
        device_battery = "gamepad,mouse";
        engine_color = "dc322f";
        font_file = "${pkgs.nerdfonts}/share/fonts/truetype/NerdFonts/IosevkaNerdFont-Bold.ttf";
        font_size = 24;
        fps_limit = "100,75,60"; # !! Monitor dependent
        fps_limit_method = "early"; # Smoother frametimes compared to late
        frame_timing = true;
        frametime_color = "859900";
        gl_vsync = -1; # Adaptive
        gpu_color = "2aa198";
        gpu_stats = true;
        no_display = true; # Hide by default
        position = "top-center";
        ram = true;
        ram_color = "d33682";
        text_color = "ffffff";
        toggle_fps_limit = "Control_L+period";
        toggle_hud = "Control_L+slash";
        vsync = 0; # Adaptive
        vram = true;
        vram_color = "6c71c4";
      };
    };
  };
}
