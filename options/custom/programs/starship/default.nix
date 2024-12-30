{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.starship;
in {
  options.custom.programs.starship = {
    enable = mkOption {default = false;};
    transience = mkOption {default = true;};
  };

  config = mkIf cfg.enable {
    # https://starship.rs/
    # https://wiki.nixos.org/wiki/Starship
    programs.starship.enable = true;

    home-manager.sharedModules = [
      {
        programs = {
          starship = {
            enable = true;
            enableTransience = cfg.transience;

            # https://starship.rs/config/
            # https://www.nerdfonts.com/cheat-sheet
            settings =
              ### Presets
              # https://starship.rs/presets/
              #?? starship preset PRESET | wl-copy
              #!! Manually import from preset file
              # https://github.com/nix-community/home-manager/issues/4231
              recursiveUpdate (
                recursiveUpdate
                (fromTOML (readFile ./presets/nerd-font-symbols.toml))
                (fromTOML (readFile ./presets/no-runtime-versions.toml))
              )
              {
                ### Overrides
                # https://starship.rs/config/#prompt
                add_newline = false;

                format = concatStrings [
                  # Top left
                  "$all"
                  "$fill"

                  # Top right
                  "$cmd_duration"
                  "$time"
                  "$battery"
                  "$os"
                  "$line_break"

                  # Bottom left
                  "$jobs"
                  "$shell"
                  "$character"
                ];

                # https://starship.rs/advanced-config/#enable-right-prompt
                right_format = concatStrings [
                  # Bottom right
                ];

                # https://starship.rs/config/#battery
                battery = {
                  format = " [$symbol]($style)";
                  charging_symbol = "󰂄";
                  discharging_symbol = "󰂃";
                  empty_symbol = "󰂎";
                  full_symbol = "󰁹";
                  unknown_symbol = "󰂑";

                  display = [
                    {
                      threshold = 15;
                      style = "bold red";
                    }

                    {
                      threshold = 30;
                      style = "bold yellow";
                    }
                  ];
                };

                # https://starship.rs/config/#character
                character = {
                  error_symbol = "[](bold red) ";
                  success_symbol = "[](bold) ";
                };

                # https://starship.rs/config/#command-duration
                cmd_duration = {
                  format = "[󱎫 $duration](#586e75)";
                  min_time = 5 * 1000; # Milliseconds
                };

                # https://starship.rs/config/#directory
                directory = {
                  format = " [$path]($style)[$read_only]($read_only_style) ";
                  repo_root_format = " [$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) ";
                  style = "bold #657b83";
                  before_repo_root_style = "bold #586e75";
                  repo_root_style = "bold";
                  fish_style_pwd_dir_length = 1;
                  truncation_length = 1;
                  truncation_symbol = "…/";
                  use_os_path_sep = false;
                };

                # https://starship.rs/config/#fill
                fill = {
                  symbol = " ";
                };

                # https://starship.rs/config/#git-branch
                git_branch = {
                  format = "[$symbol$branch(:$remote_branch)]($style) ";
                };

                # https://starship.rs/config/#hostname
                hostname = {
                  format = "[[@](#586e75)$hostname]($style) ";
                  style = "bold";
                };

                # https://starship.rs/config/#local-ip
                localip = {
                  disabled = false;
                };

                # https://starship.rs/config/#os
                os = {
                  disabled = false;
                  style = "bold";

                  # "ICON " required for proper size
                  symbols = {
                    AIX = "  ";
                    Alpaquita = "  ";
                    AlmaLinux = "  ";
                    Alpine = "  ";
                    Amazon = "  ";
                    Android = "  ";
                    Arch = "  ";
                    Artix = "  ";
                    CentOS = "  ";
                    Debian = "  ";
                    DragonFly = "  ";
                    Emscripten = " 󰯁 ";
                    EndeavourOS = "  ";
                    Fedora = "  ";
                    FreeBSD = "  ";
                    Garuda = "  ";
                    Gentoo = "  ";
                    HardenedBSD = " 󰥯 ";
                    Illumos = "  ";
                    Kali = "  ";
                    Linux = " 󰌽 ";
                    Mabox = "  ";
                    Macos = "  ";
                    Manjaro = "  ";
                    Mariner = "  ";
                    MidnightBSD = " 󰖔 ";
                    Mint = " 󰣭 ";
                    NetBSD = "  ";
                    NixOS = "  ";
                    OpenBSD = "  ";
                    OpenCloudOS = "  ";
                    openEuler = " 󰏒 ";
                    openSUSE = "  ";
                    OracleLinux = "  ";
                    Pop = "  ";
                    Raspbian = "  ";
                    Redhat = "  ";
                    RedHatEnterprise = "  ";
                    RockyLinux = "  ";
                    Redox = " 󰙨 ";
                    Solus = "  ";
                    SUSE = "  ";
                    Ubuntu = "  ";
                    Ultramarine = " 󰜃 ";
                    Unknown = "  ";
                    Void = "  ";
                    Windows = "  ";
                  };
                };

                # https://starship.rs/config/#shell
                shell = {
                  disabled = false;
                  style = "bold";

                  bash_indicator = " ";
                  cmd_indicator = " ";
                  elvish_indicator = "󰲋 ";
                  fish_indicator = " ";
                  ion_indicator = " ";
                  nu_indicator = "󰟢 ";
                  powershell_indicator = " ";
                  tcsh_indicator = " ";
                  unknown_indicator = " ";
                  xonsh_indicator = " ";
                  zsh_indicator = " ";
                };

                # https://starship.rs/config/#time
                time = {
                  disabled = false;
                  format = " [$time]($style)";
                  style = "bold #657b83";

                  # https://docs.rs/chrono/latest/chrono/format/strftime/index.html
                  time_format = "%a %b %-d %-I:%M%P";
                };

                # https://starship.rs/config/#username
                username = {
                  format = "[$user]($style)";
                  style_user = "bold #6c71c4";
                  show_always = true;
                };
              };
          };

          fish.functions = mkIf cfg.transience {
            # https://starship.rs/advanced-config/#transientprompt-and-transientrightprompt-in-fish
            starship_transient_prompt_func = ''
              starship module character
            '';
          };
        };
      }
    ];
  };
}
