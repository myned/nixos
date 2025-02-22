{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.onlyoffice;

  onlyoffice-desktopeditors = "${getExe pkgs.onlyoffice-bin} --system-title-bar --xdg-desktop-portal";
in {
  options.custom.programs.onlyoffice = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # https://github.com/ONLYOFFICE/DesktopEditors
    environment.systemPackages = [pkgs.onlyoffice-bin];

    home-manager.sharedModules = [
      {
        xdg.desktopEntries = {
          # https://github.com/ONLYOFFICE/desktop-apps/blob/master/win-linux/package/linux/common/desktopeditors.desktop.m4
          onlyoffice-desktopeditors = {
            name = "ONLYOFFICE Desktop Editors";
            genericName = "Document Editor";
            comment = "Edit office documents";
            type = "Application";
            exec = "${onlyoffice-desktopeditors} %U";
            terminal = false;
            icon = "onlyoffice-desktopeditors";
            categories = ["Office" "WordProcessor" "Spreadsheet" "Presentation"];
            mimeType = ["application/vnd.oasis.opendocument.text" "application/vnd.oasis.opendocument.text-template" "application/vnd.oasis.opendocument.text-web" "application/vnd.oasis.opendocument.text-master" "application/vnd.sun.xml.writer" "application/vnd.sun.xml.writer.template" "application/vnd.sun.xml.writer.global" "application/msword" "application/vnd.ms-word" "application/x-doc" "application/rtf" "text/rtf" "application/vnd.wordperfect" "application/wordperfect" "application/vnd.openxmlformats-officedocument.wordprocessingml.document" "application/vnd.ms-word.document.macroenabled.12" "application/vnd.openxmlformats-officedocument.wordprocessingml.template" "application/vnd.ms-word.template.macroenabled.12" "application/vnd.oasis.opendocument.spreadsheet" "application/vnd.oasis.opendocument.spreadsheet-template" "application/vnd.sun.xml.calc" "application/vnd.sun.xml.calc.template" "application/msexcel" "application/vnd.ms-excel" "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" "application/vnd.ms-excel.sheet.macroenabled.12" "application/vnd.openxmlformats-officedocument.spreadsheetml.template" "application/vnd.ms-excel.template.macroenabled.12" "application/vnd.ms-excel.sheet.binary.macroenabled.12" "text/csv" "text/spreadsheet" "application/csv" "application/excel" "application/x-excel" "application/x-msexcel" "application/x-ms-excel" "text/comma-separated-values" "text/tab-separated-values" "text/x-comma-separated-values" "text/x-csv" "application/vnd.oasis.opendocument.presentation" "application/vnd.oasis.opendocument.presentation-template" "application/vnd.sun.xml.impress" "application/vnd.sun.xml.impress.template" "application/mspowerpoint" "application/vnd.ms-powerpoint" "application/vnd.openxmlformats-officedocument.presentationml.presentation" "application/vnd.ms-powerpoint.presentation.macroenabled.12" "application/vnd.openxmlformats-officedocument.presentationml.template" "application/vnd.ms-powerpoint.template.macroenabled.12" "application/vnd.openxmlformats-officedocument.presentationml.slide" "application/vnd.openxmlformats-officedocument.presentationml.slideshow" "application/vnd.ms-powerpoint.slideshow.macroEnabled.12" "x-scheme-handler/oo-office" "text/docxf" "text/oform"];

            actions = {
              NewDocument = {
                name = "New document";
                exec = "${onlyoffice-desktopeditors} --new:word";
              };

              NewSpreadsheet = {
                name = "New spreadsheet";
                exec = "${onlyoffice-desktopeditors} --new:cell";
              };

              NewPresentation = {
                name = "New presentation";
                exec = "${onlyoffice-desktopeditors} --new:slide";
              };

              NewForm = {
                name = "New PDF form";
                exec = "${onlyoffice-desktopeditors} --new:form";
              };
            };
          };
        };
      }
    ];
  };
}
