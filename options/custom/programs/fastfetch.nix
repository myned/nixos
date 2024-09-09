{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  fastfetch = "${pkgs.fastfetch}/bin/fastfetch";

  cfg = config.custom.programs.fastfetch;
in
{
  options.custom.programs.fastfetch = {
    enable = mkOption { default = false; };
    greet = mkOption { default = false; };
  };

  config = mkIf cfg.enable {
    # https://github.com/fastfetch-cli/fastfetch
    environment.systemPackages = [ pkgs.fastfetch ];

    # System info greeting
    programs.fish.interactiveShellInit = mkIf cfg.greet ''
      # If not root, print greeting
      if test (id -u) -ne 0
        function fish_greeting
          ${fastfetch}
        end
      end
    '';

    # https://github.com/fastfetch-cli/fastfetch
    #!! Option not available, files written directly
    home-manager.users.${config.custom.username}.home.file.".config/fastfetch/config.jsonc".text = ''
      {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {
          "source": "none",
        },
        "modules": [
          "publicip",
          "datetime",
          "uptime",
          "processes",
          "cpuusage",
          "memory",
          "swap",
          "disk",
          "diskio",
          "netio",
        ]
      }
    '';
  };
}
