{
  config,
  lib,
  options,
  ...
}:
with lib; let
  cfg = config.custom.browsers;
in {
  options.custom.browsers = {
    enable = mkEnableOption "browsers";
  };

  config.custom.browsers = {
    chromium.enable = true;
    firefox.enable = true;
  };
}
