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
        core_load = true;
        frame_timing = true;
        gpu_stats = true;
        no_display = true; # Hide by default
        ram = true;
        vram = true;
        background_alpha = 0;
        font_size = 24;
        fps_limit = "100,75,60"; # !! Monitor dependent
        background_color = "002b36";
        cpu_color = "268bd2";
        device_battery = "gamepad,mouse";
        engine_color = "dc322f";
        font_file = "${pkgs.nerdfonts}/share/fonts/truetype/NerdFonts/IosevkaNerdFont-Bold.ttf";
        fps_limit_method = "early"; # Smoother frametimes compared to late
        frametime_color = "859900";
        gpu_color = "2aa198";
        position = "top-center";
        ram_color = "d33682";
        text_color = "ffffff";
        toggle_fps_limit = "Control_L+period";
        toggle_hud = "Control_L+slash";
        vram_color = "6c71c4";
      };
    };
  };
}
