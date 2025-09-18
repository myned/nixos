{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.polkit;
in {
  options.custom.programs.polkit = {
    enable = mkEnableOption "polkit";

    agent = mkOption {
      default = null;
      description = "Package of the polkit agent to use";
      example = pkgs.pantheon.pantheon-agent-polkit;

      type = with types;
        nullOr (enum (with pkgs; [
          pantheon.pantheon-agent-polkit
          polkit_gnome
        ]));
    };

    bypassPrompt = mkOption {
      default = false;
      description = "Whether to bypass the polkit password prompt";
      example = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Polkit
    #?? pkexec echo
    security.polkit = {
      enable = true;

      # https://wiki.archlinux.org/title/Polkit#Bypass_password_prompt
      extraConfig = mkIf cfg.bypassPrompt ''
        polkit.addRule(function(action, subject) {
          if (subject.isInGroup("wheel")) { return polkit.Result.YES; }
        });
      '';
    };

    # https://wiki.nixos.org/wiki/Polkit#Authentication_agents
    systemd.user.services.${cfg.agent.pname} = mkIf (!isNull cfg.agent) {
      enable = true;
      wantedBy = ["graphical-session.target"];

      unitConfig = {
        Description = cfg.agent.pname;
        After = ["graphical-session.target"];
        Wants = ["graphical-session.target"];
      };

      serviceConfig = let
        agent =
          if cfg.agent == pkgs.pantheon.pantheon-agent-polkit
          then "policykit-1-pantheon/io.elementary.desktop.agent-polkit"
          else if cfg.agent == pkgs.polkit_gnome
          then "polkit-gnome-authentication-agent-1"
          else "";
      in {
        Type = "simple";
        ExecStart = "${cfg.agent}/libexec/${agent}";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
}
