{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.custom.programs.nano;
in {
  options.custom.programs.nano.enable = mkOption {default = false;};

  config = mkIf cfg.enable {
    # https://wiki.archlinux.org/title/Nano
    # https://www.nano-editor.org
    programs.nano = {
      enable = true;

      # https://www.nano-editor.org/dist/latest/nanorc.5.html
      #?? man nanorc
      nanorc = ''
        set autoindent
        set magic
        set minibar
        set linenumbers
        set tabsize 2
        set tabstospaces
        set trimblanks
      '';
    };
  };
}
