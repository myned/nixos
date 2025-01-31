{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.zed;
in {
  options.custom.programs.zed = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    home-manager.sharedModules = [
      {
        # https://zed.dev/
        # https://github.com/zed-industries/zed
        programs.zed-editor = {
          enable = true;

          extraPackages = with pkgs; [
            alejandra # nix
            nixd # nix
            shellcheck # basher
            shfmt # basher
          ];

          # https://zed.dev/docs/extensions
          # https://github.com/zed-industries/extensions/tree/main/extensions
          extensions = [
            "basher" # https://github.com/d1y/bash.zed
            "git-firefly" # https://github.com/d1y/git_firefly
            "nix" # https://github.com/zed-extensions/nix
          ];

          # https://zed.dev/docs/key-bindings
          userKeymaps = [
            {
              bindings = {
                "escape" = "menu::Cancel";
                "ctrl-," = "zed::OpenSettings";
                "ctrl-o" = "workspace::Open";
              };
            }
            {
              context = "Editor";
              bindings = {
                "alt-enter" = "editor::DuplicateLineDown";
                "backspace" = "editor::Backspace";
                "shift-backspace" = "editor::Backspace";
                "delete" = "editor::Delete";
                "tab" = "editor::Tab";
                "shift-tab" = "editor::TabPrev";
                "ctrl-k" = "editor::CutToEndOfLine";
                "ctrl-k ctrl-q" = "editor::Rewrap";
                "ctrl-k q" = "editor::Rewrap";
                "ctrl-backspace" = "editor::DeleteToPreviousWordStart";
                "ctrl-delete" = "editor::DeleteToNextWordEnd";
                "shift-delete" = "editor::Cut";
                "ctrl-insert" = "editor::Copy";
                "shift-insert" = "editor::Paste";
                "ctrl-y" = "editor::Redo";
                "ctrl-z" = "editor::Undo";
                "ctrl-shift-z" = "editor::Redo";
                "up" = "editor::MoveUp";
                "ctrl-up" = "editor::LineUp";
                "ctrl-down" = "editor::LineDown";
                "pageup" = "editor::MovePageUp";
                "alt-pageup" = "editor::PageUp";
                "shift-pageup" = "editor::SelectPageUp";
                "home" = "editor::MoveToBeginningOfLine";
                "down" = "editor::MoveDown";
                "pagedown" = "editor::MovePageDown";
                "alt-pagedown" = "editor::PageDown";
                "shift-pagedown" = "editor::SelectPageDown";
                "end" = "editor::MoveToEndOfLine";
                "left" = "editor::MoveLeft";
                "right" = "editor::MoveRight";
                "ctrl-left" = "editor::MoveToPreviousWordStart";
                "ctrl-right" = "editor::MoveToNextWordEnd";
                "ctrl-home" = "editor::MoveToBeginning";
                "ctrl-end" = "editor::MoveToEnd";
                "shift-up" = "editor::SelectUp";
                "shift-down" = "editor::SelectDown";
                "shift-left" = "editor::SelectLeft";
                "shift-right" = "editor::SelectRight";
                "ctrl-shift-left" = "editor::SelectToPreviousWordStart";
                "ctrl-shift-right" = "editor::SelectToNextWordEnd";
                "ctrl-shift-home" = "editor::SelectToBeginning";
                "ctrl-shift-end" = "editor::SelectToEnd";
                "ctrl-a" = "editor::SelectAll";
                "ctrl-l" = "editor::SelectLine";
                "ctrl-shift-i" = "editor::Format";
                "ctrl-alt-space" = "editor::ShowCharacterPalette";
                "ctrl-;" = "editor::ToggleLineNumbers";
                "ctrl-k ctrl-r" = "editor::RevertSelectedHunks";
                "ctrl-'" = "editor::ToggleHunkDiff";
                "ctrl-\"" = "editor::ExpandAllHunkDiffs";
                "ctrl-i" = "editor::ShowSignatureHelp";
                "alt-g b" = "editor::ToggleGitBlame";
                "menu" = "editor::OpenContextMenu";
                "shift-f10" = "editor::OpenContextMenu";
              };
            }
          ];

          # https://zed.dev/docs/configuring-zed
          userSettings = {
            always_treat_brackets_as_autoclosed = true;

            assistant = {
              default_model = {
                model = "claude-3-5-sonnet-latest";
                provider = "zed.dev";
              };

              version = 2;
            };

            auto_install_extensions = false;
            auto_signature_help = true;

            # BUG: Font variations are not currently supported
            # https://github.com/zed-industries/zed/issues/5028
            #// buffer_font_family = "monospace";
            buffer_font_family = "IosevkaTermSlab Nerd Font Propo";

            buffer_font_size = 18;
            buffer_line_height.custom = 1.5;

            collaboration_panel = {
              button = false;
              dock = "right";
            };

            cursor_blink = false;

            features = {
              inline_completion_provider = "none";
            };

            git = {
              inline_blame.enabled = false;
            };

            indent_guides = {
              active_line_width = 2;
            };

            load_direnv = "shell_hook";
            middle_click_paste = false;

            outline_panel = {
              dock = "right";
              indent_size = 10;
            };

            preferred_line_length = 120;

            project_panel = {
              default_width = 200;
              indent_guides.show = "never";
              indent_size = 10;
            };

            seed_search_query_from_cursor = "selection";
            show_user_picture = false;

            # TODO: Show trailing whitespace when supported
            # https://github.com/zed-industries/zed/issues/5237
            show_whitespaces = "selection";

            soft_wrap = "preferred_line_length";
            tab_size = 2;

            tabs = {
              file_icons = true;
              git_status = true;
              show_diagnostics = "all";
            };

            telemetry = {
              metrics = true;
              diagnostics = true;
            };

            theme = {
              mode = "system";
              light = "Solarized Light";
              dark = "Solarized Dark";
            };

            ui_font_family = config.custom.settings.fonts.sans-serif;
            ui_font_size = 18;

            # Language-specific
            # https://zed.dev/docs/configuring-languages
            languages = {
              Nix = {
                formatter.external.command = "alejandra";
                language_servers = ["nixd" "!nil"];
              };
            };

            # TODO: Add missing syntax in highlights.scm
            # Theme overrides
            # https://zed.dev/docs/themes#theme-overrides
            # https://zed.dev/docs/extensions/languages#syntax-highlighting
            # https://github.com/zed-industries/zed/blob/main/assets/themes/solarized/solarized.json
            # https://github.com/zed-industries/zed/issues/20525
            #?? editor: copy highlight json
            "experimental.theme_overrides" = {
              # https://github.com/zed-industries/zed/issues/4655
              players = [
                {
                  cursor = "#93a1a1";
                  background = "#93a1a1";
                  selection = "#93a1a11A"; # 10%
                }
              ];

              "scrollbar.thumb.background" = "#073642";
              "scrollbar.thumb.border" = "#00000000";

              syntax = {
                _expr.color = "#b58900";
                _id.color = "#93a1a1";
                attribute.color = "#93a1a1";
                boolean.color = "#cb4b16";
                comment.color = "#586e75";
                "comment.doc".color = "#586e75";
                constant.color = "#93a1a1";
                "constant.builtin".color = "#93a1a1";
                constructor.color = "#b58900";
                embedded.color = "#657b83";
                emphasis.color = "#93a1a1";
                "emphasis.strong".color = "#93a1a1";
                enum.color = "#b58900";
                function.color = "#268bd2";
                "function.builtin".color = "#268bd2";
                "function.call".color = "#268bd2";
                hint.color = "#657b83";
                keyword.color = "#d33682";
                "keyword.exception".color = "#d33682";
                label.color = "#93a1a1";
                link_text.color = "#93a1a1";
                link_uri.color = "#93a1a1";
                number.color = "#2aa198";
                operator.color = "#657b83";
                predictive.color = "#657b83";
                preproc.color = "#93a1a1";
                primary.color = "#93a1a1";
                property.color = "#93a1a1";
                punctuation.color = "#657b83";
                "punctuation.bracket".color = "#657b83";
                "punctuation.delimiter".color = "#657b83";
                "punctuation.list_marker".color = "#657b83";
                "punctuation.special".color = "#657b83";
                string.color = "#859900";
                "string.escape".color = "#cb4b16";
                "string.regex".color = "#cb4b16";
                "string.special".color = "#cb4b16";
                "string.special.symbol".color = "#cb4b16";
                tag.color = "#93a1a1";
                "tag.doctype".color = "#93a1a1";
                "text.literal".color = "#93a1a1";
                title.color = "#93a1a1";
                type.color = "#b58900";
                variable.color = "#93a1a1";
                "variable.member".color = "#93a1a1";
                "variable.parameter".color = "#6c71c4";
                "variable.special".color = "#93a1a1";
                variant.color = "#93a1a1";
              };
            };
          };
        };
      }
    ];
  };
}
