{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  polkit-gnome-authentication-agent-1 = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";

  cfg = config.custom.programs.polkit;
in {
  options.custom.programs.polkit = {
    enable = mkOption {default = false;};
    agent = mkOption {default = true;};
    bypass = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Polkit
    #?? pkexec echo
    security.polkit = {
      enable = true;

      # https://wiki.archlinux.org/title/Polkit#Bypass_password_prompt
      extraConfig = mkIf cfg.bypass ''
        polkit.addRule(function(action, subject) {
          if (subject.isInGroup("wheel")) { return polkit.Result.YES; }
        });
      '';
    };

    # https://wiki.nixos.org/wiki/Polkit#Authentication_agents
    systemd.user.services.polkit-gnome-authentication-agent-1 = mkIf cfg.agent {
      enable = true;
      wantedBy = ["graphical-session.target"];

      unitConfig = {
        Description = "polkit-gnome-authentication-agent-1";
        After = ["graphical-session.target"];
        Wants = ["graphical-session.target"];
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = polkit-gnome-authentication-agent-1;
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
