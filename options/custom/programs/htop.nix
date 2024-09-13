{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.htop;
in {
  options.custom.programs.htop.enable = mkOption {default = false;};

  config.home-manager.users.${config.custom.username} = mkIf cfg.enable {
    # https://github.com/htop-dev/htop
    programs.htop = {
      enable = true;

      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.htop.settings
      #!! Not up-to-date, some config is imperative
      settings =
        {
          account_guest_in_cpu_meter = 1;
          all_branches_collapsed = 0;
          color_scheme = 0;
          cpu_count_from_one = 1;
          degree_fahrenheit = 0;
          delay = 30;
          detailed_cpu_time = 0;
          enable_mouse = 1;
          find_comm_in_cmdline = 0;
          header_layout = "two_50_50";
          header_margin = 1;
          hide_function_bar = 0;
          hide_kernel_threads = 1;
          hide_running_in_container = 0;
          hide_userland_threads = 1;
          highlight_base_name = 1;
          highlight_changes = 1;
          highlight_changes_delay_secs = 3;
          highlight_deleted_exe = 1;
          highlight_megabytes = 1;
          highlight_threads = 1;
          screen_tabs = 1;
          shadow_distribution_path_prefix = 0;
          shadow_other_users = 0;
          show_cpu_frequency = 0;
          show_cpu_temperature = 0;
          show_cpu_usage = 0;
          show_merged_command = 0;
          show_program_path = 0;
          show_thread_names = 0;
          sort_direction = -1;
          sort_key = 46;
          strip_exe_from_cmdline = 0;
          tree_sort_direction = 1;
          tree_sort_key = 0;
          tree_view = 0;
          tree_view_always_by_pid = 0;
          update_process_names = 1;

          #!! Variable max of 120
          fields = with config.home-manager.users.${config.custom.username}.lib.htop.fields; [
            PID
            USER
            PROCESSOR
            PERCENT_CPU
            PERCENT_MEM
            IO_READ_RATE
            IO_WRITE_RATE
            125 # CWD
            COMM
          ];
        }
        // (
          with config.home-manager.users.${config.custom.username}.lib.htop;
            leftMeters [
              (bar "LeftCPUs4")
              (text "Blank")
              (bar "CPU")
              (bar "MemorySwap")
              (text "System")
              (text "DateTime")
            ]
        )
        // (
          with config.home-manager.users.${config.custom.username}.lib.htop;
            rightMeters [
              (bar "RightCPUs4")
              (text "Blank")
              (bar "NetworkIO")
              (bar "DiskIO")
              (text "Hostname")
              (text "Uptime")
            ]
        );
    };

    # https://github.com/nix-community/home-manager/issues/4947
    xdg.configFile."htop/htoprc".force = true; # Force overwrite config file
  };
}
