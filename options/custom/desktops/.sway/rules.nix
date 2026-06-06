{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.desktops.sway.rules;
in {
  options.custom.desktops.sway.rules.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://i3wm.org/docs/
        wayland.windowManager.sway.config.window.commands = let
          command = command: {inherit command;};

          # Boilerplate criteria
          #?? criteria = <"ATTR"|{ATTRS = "EXPR"}> <"EXPR"|null>
          criteria = attr: expr: {
            criteria = with builtins;
              if isAttrs attr
              then (mapAttrs (a: e: "^${e}$") attr)
              else {
                ${attr} =
                  if isNull expr
                  then true
                  else "^${expr}$";
              };
          };

          class = expr: criteria "app_id" expr;
          floating = criteria "floating" null;
          mark = expr: criteria "con_mark" expr;
          title = expr: criteria "title" expr;

          attrs = attrs: criteria attrs null;
        in [
          ### Defaults
          # HACK: Prefer default_floating_border when fixed upstream
          # https://github.com/swaywm/sway/issues/7360
          (floating // command "border normal 0")

          ### Marks
          (mark "browser" // command "move to workspace 1")
          (mark "dropdown" // command "move to scratchpad")
          (mark "pip" // command "border none, floating enable, sticky enable")
          (mark "terminal" // command "move to workspace terminal")

          (title "Picture.in.[Pp]icture" // command "mark pip")

          ### Overrides
          (attrs {
              app_id = "firefox";
              title = ".*Firefox.*";
            }
            // command "layout tabbed")
          (attrs {
              app_id = "firefox";
              title = "Extension.*";
            }
            // command "floating enable")
        ];
      }
    ];
  };
}
