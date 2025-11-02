{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.custom.programs.zed;
  hm = config.home-manager.users.${config.custom.username};

  hujsonfmt = getExe pkgs.hujsonfmt;
in {
  options.custom.programs.zed = {
    enable = mkOption {default = false;};
  };

  config = mkIf cfg.enable {
    # Extension dependencies
    environment.systemPackages = with pkgs; [
      alejandra # nix
      ansible # ansible
      #// ansible-language-server # ansible
      ansible-lint # ansible
      astro-language-server # astro
      basedpyright # basedpyright
      blueprint-compiler # blueprint
      caddy # caddyfile
      docker-compose-language-service # docker-compose
      dockerfile-language-server # dockerfile
      jdt-language-server # java
      nginx-language-server # nginx
      nil # nix
      nixd # nix
      nushell # nu
      phpactor # php
      powershell # powershell
      powershell-editor-services # powershell
      shellcheck # basher
      shfmt # basher
      simple-completion-language-server # snippets
      svelte-language-server # svelte
      vscode-langservers-extracted # html
      yaml-language-server # yaml
    ];

    home-manager.users.${config.custom.username} = {
      # https://zed.dev/
      # https://github.com/zed-industries/zed
      # https://wiki.nixos.org/wiki/Zed
      #!! Mutable settings
      programs.zed-editor = {
        enable = true;

        # https://zed.dev/docs/extensions
        # https://github.com/zed-industries/extensions/tree/main/extensions
        extensions = [
          "ansible" # https://github.com/kartikvashistha/zed-ansible
          "astro" # https://github.com/zed-extensions/astro
          #// "bearded-icon-theme" # https://github.com/sethstha/bearded-icons-theme
          "basedpyright" # https://github.com/m1guer/basedpyright-zed
          "basher" # https://github.com/d1y/bash.zed
          "blueprint" # https://github.com/tfuxu/zed-blueprint
          "caddyfile" # https://github.com/nusnewob/caddyfile-zed
          "colored-zed-icons-theme" # https://github.com/TheRedXD/zed-icons-colored-theme
          "csv" # https://github.com/huacnlee/zed-csv
          #// "discord-presence" # https://github.com/xhyrom/zed-discord-presence
          "docker-compose" # https://github.com/eth0net/zed-docker-compose
          "dockerfile" # https://github.com/d1y/dockerfile.zed
          "env" # https://github.com/zarifpour/zed-env
          "fish" # https://github.com/hasit/zed-fish
          "git-firefly" # https://github.com/d1y/git_firefly
          "html" # https://github.com/zed-industries/zed/tree/main/extensions/html
          "ini" # https://github.com/bajrangCoder/zed-ini
          "java" # https://github.com/zed-extensions/java
          "jinja2" # https://github.com/ArcherHume/jinja2-support
          "log" # https://github.com/zed-extensions/log
          "make" # https://github.com/caius/zed-make
          #// "material-icon-theme" # https://github.com/zed-extensions/material-icon-theme
          #// "monospace-icon-theme" # https://github.com/irmhonde/monospace-icon-theme
          "nginx" # https://github.com/d1y/nginx-zed
          "nix" # https://github.com/zed-extensions/nix
          "nu" # https://github.com/zed-extensions/nu
          "php" # https://github.com/zed-extensions/php
          "powershell" # https://github.com/wingyplus/zed-powershell

          # TODO: Add dependencies
          # https://github.com/NixOS/nixpkgs/issues/229337
          #// "pylsp" # https://github.com/rgbkrk/python-lsp-zed-extension

          # BUG: scss-lsp/some-sass-lsp not packaged yet
          # https://github.com/NixOS/nixpkgs/issues/380280
          #// "scss" # https://github.com/bajrangCoder/zed-scss

          "sql" # https://github.com/zed-extensions/sql
          "svelte" # https://github.com/zed-extensions/svelte
          "toml" # https://github.com/zed-industries/zed/tree/main/extensions/toml
          "tmux" # https://github.com/dangh/zed-tmux

          # BUG: unocss-language-server not packaged yet
          # https://github.com/NixOS/nixpkgs/issues/270993
          "unocss" # https://github.com/bajrangCoder/zed-unocss

          "xml" # https://github.com/sweetppro/zed-xml
        ];

        # https://zed.dev/docs/key-bindings
        userKeymaps = let
          global = bindings: {inherit bindings;};
          context = context: bindings: {inherit context bindings;};
        in [
          (global {
            "alt-\\" = "workspace::ToggleBottomDock";
            "alt-a" = "agent::ToggleFocus";
            "alt-c" = "collab_panel::ToggleFocus";
            "alt-f" = "project_search::ToggleFocus";
            "alt-g" = "git_panel::ToggleFocus";
            "alt-p" = "project_panel::ToggleFocus";
            "alt-t" = "terminal_panel::ToggleFocus";

            "alt-escape" = "workspace::CloseAllDocks";
            "alt-space" = "command_palette::Toggle";
            "alt-tab" = "workspace::ToggleLeftDock";

            "alt-shift-tab" = "workspace::ToggleRightDock";
          })

          (context "Editor" {
            "alt-backspace" = "editor::DeleteLine";
            "alt-enter" = "editor::DuplicateLineDown";
            "alt-left" = "editor::MoveToBeginningOfLine";
            "alt-right" = "editor::MoveToEndOfLine";
            "ctrl-enter" = "editor::NewlineBelow";

            "alt-shift-enter" = "editor::DuplicateLineUp";
          })

          (context "Editor && showing_completions" {
            "enter" = "editor::Newline";
          })

          # https://zed.dev/docs/key-bindings#forward-keys-to-terminal
          (context "Terminal" {
            "ctrl-s" = ["terminal::SendKeystroke" "ctrl-s"];
          })
        ];

        # https://zed.dev/docs/configuring-zed
        userSettings = {
          always_treat_brackets_as_autoclosed = true;
          auto_install_extensions = false;
          base_keymap = "VSCode";

          # BUG: Font variations are not currently supported
          # https://github.com/zed-industries/zed/issues/5028
          #// buffer_font_family = "monospace";
          buffer_font_family = mkForce "IosevkaTermSlab Nerd Font Propo";
          buffer_line_height.custom = 1.5;
          ui_font_size = mkForce 18;

          chat_panel.default_width = 300;

          collaboration_panel = {
            button = false;
            default_width = 300;
            dock = "right";
          };

          cursor_blink = false;

          # BUG: Does not disable
          edit_predictions.disabled_globs = [
            "**/*.env"
            "**/*.pem"
            "**/*.key"
            "**/*.cert"
            "**/*.crt"
            "**/.dev.vars"
            "**/secrets.yml"
            "**/secrets/**"
            "**/tmp/**"
          ];

          edit_predictions_disabled_in = ["comment"];
          git.inline_blame.enabled = false;
          git_panel.default_width = 300;
          icon_theme = "Colored Zed Icons Theme Dark";
          indent_guides.active_line_width = 2;
          inlay_hints.enabled = true;
          load_direnv = "shell_hook";
          middle_click_paste = false;
          notification_panel.default_width = 300;

          outline_panel = {
            default_width = 300;
            dock = "right";
            indent_size = 10;
          };

          preferred_line_length = 120;

          project_panel = {
            auto_fold_dirs = true;
            auto_reveal_entries = true;
            default_width = 300;
            entry_spacing = "comfortable";
            indent_guides.show = "never";
            indent_size = 10;
            scrollbar.show = "never";
          };

          seed_search_query_from_cursor = "selection";
          show_edit_predictions = true;
          show_signature_help_after_edits = true;

          # TODO: Show trailing whitespace when supported
          # https://github.com/zed-industries/zed/issues/5237
          show_whitespaces = "selection";

          #// soft_wrap = "preferred_line_length";
          tab_size = 2;

          tabs = {
            git_status = true;
            show_diagnostics = "all";
          };

          #!! Enable telemetry
          telemetry = {
            diagnostics = true;
            metrics = true;
          };

          terminal = {
            default_width = 500;
            default_height = 200;
            line_height = "standard";
            minimum_contrast = 0;

            env = {
              EDITOR = "zeditor --wait";
            };
          };

          title_bar = {
            show_branch_icon = true;
            show_branch_name = true;
            show_onboarding_banner = false;
            show_project_items = true;
            show_sign_in = false;
            show_user_picture = false;
            show_menus = false;
          };

          # Filetype associations
          # https://zed.dev/docs/configuring-languages#file-associations
          file_types = {
            # https://github.com/kartikvashistha/zed-ansible?tab=readme-ov-file#filetype-detection
            Ansible = [
              "**/defaults/*.yaml"
              "**/defaults/*.yml"
              "**/group_vars/*.yaml"
              "**/group_vars/*.yml"
              "**/handlers/*.yaml"
              "**/handlers/*.yml"
              "**/meta/*.yaml"
              "**/meta/*.yml"
              "**/playbooks/*.yaml"
              "**/playbooks/*.yml"
              "**/tasks/*.yaml"
              "**/tasks/*.yml"
              "*.ansible.yaml"
              "*.ansible.yml"
              "*playbook*.yaml"
              "*playbook*.yml"
            ];

            # https://github.com/tailscale/hujson?tab=readme-ov-file#visual-studio-code-association
            JSONC = [
              "*.hujson"
            ];
          };

          # Languages
          # https://zed.dev/docs/configuring-languages
          languages = {
            # https://zed.dev/docs/languages/astro
            Astro = {
              formatter.external = {
                command = "npx";
                arguments = ["prettier" "--parser=astro"];
              };
            };

            # https://github.com/nusnewob/caddyfile-zed
            Caddyfile = {
              format_on_save = "on";
              tab_size = 2;

              formatter.external = {
                command = "caddy";
                arguments = ["fmt" "-"];
              };
            };

            # FIXME: Applies to JSON files
            # https://zed.dev/docs/languages/json
            # JSONC = {
            #   formatter.external.command = hujsonfmt;
            # };

            # https://zed.dev/docs/languages/markdown
            Markdown = {
              format_on_save = "on";
              remove_trailing_whitespace_on_save = false;
            };

            Nix = {
              # https://github.com/oxalica/nil
              # https://github.com/nix-community/nixd
              language_servers = ["!nil" "nixd"];
            };

            # YAML = {
            #   language_servers = ["ansible" "ansible-lint"];
            # };
          };

          # Language servers
          # https://zed.dev/docs/configuring-languages#configuring-language-servers
          lsp = {
            # https://github.com/tailscale/hujson?tab=readme-ov-file#visual-studio-code-association
            # json-language-server.settings.json.schemas = [
            #   {
            #     fileMatch = ["*.hujson"];
            #     schema.allowTrailingCommas = true;
            #   }
            # ];

            # https://github.com/oxalica/nil/blob/main/docs/configuration.md
            nil.settings = {
              formatting.command = ["alejandra"];
              #// nix.flake.autoArchive = true;
            };

            # https://github.com/nix-community/nixd/blob/main/nixd/docs/configuration.md
            nixd.settings = {
              formatting.command = ["alejandra"];
            };
          };

          # Language models
          # https://zed.dev/docs/assistant/assistant
          agent = {
            default_model = {
              model = "codegemma:7b";
              provider = "ollama";
            };

            default_width = 500;
          };

          # https://zed.dev/docs/completions#edit-predictions
          features.edit_prediction_provider = "zed";

          # https://zed.dev/docs/assistant/configuration
          language_models = {
            ollama.api_url = "http://${config.custom.services.ollama.server}:11434";
          };

          # TODO: Add missing syntax in highlights.scm
          # Theme overrides
          # https://zed.dev/docs/themes#theme-overrides
          # https://zed.dev/docs/extensions/languages#syntax-highlighting
          # https://github.com/zed-industries/zed/issues/20525
          # https://github.com/zed-industries/zed/blob/main/assets/themes/one/one.json
          # https://github.com/zed-industries/zed/blob/main/assets/themes/solarized/solarized.json
          # https://github.com/tinted-theming/schemes/blob/spec-0.11/base16/solarized-dark.yaml
          #?? editor: copy highlight json
          "experimental.theme_overrides" = with config.lib.stylix.colors; {
            ### Styles
            "background" = "#${base01}";
            "border" = "#${base00}";
            "border.variant" = "#${base00}";
            "created" = "#${base0B}";
            "created.background" = "#${base0B}20";
            "created.border" = "#${base0B}40";
            "deleted" = "#${base08}";
            "deleted.background" = "#${base08}20";
            "deleted.border" = "#${base08}40";
            "editor.active_wrap_guide" = "#${base01}";
            "editor.document_highlight.read_background" = "#${base01}";
            "editor.document_highlight.write_background" = "#${base01}";
            "editor.invisible" = "#${base03}";
            "editor.wrap_guide" = "#${base01}";

            # TODO: Submit PR to fix
            # BUG: (ghost_)element is incorrectly defined as nested objects instead of strings
            # https://github.com/tinted-theming/base16-zed/blob/main/templates/default.mustache
            "element.active" = "#${base03}20";
            "element.background" = "#${base00}00";
            "element.disabled" = "#${base03}";
            "element.hover" = "#${base03}10";
            "element.selected" = "#${base03}40";
            "ghost_element.active" = "#${base03}20";
            "ghost_element.background" = "#${base00}00";
            "ghost_element.disabled" = "#${base03}";
            "ghost_element.hover" = "#${base03}10";
            "ghost_element.selected" = "#${base03}40";

            "icon.accent" = "#${base0F}";
            "panel.background" = "#${base01}";
            "panel.focused_border" = "#${base0F}";
            "predictive" = "#${base06}";
            "predictive.background" = "#${base06}20";
            "predictive.border" = "#${base06}40";
            "scrollbar.thumb.background" = "#${base03}40";
            "scrollbar.thumb.border" = "#${base03}00";
            "scrollbar.thumb.hover_background" = "#${base03}";
            "search.match_background" = "#${base03}40";
            "status_bar.background" = "#${base00}";
            "tab.active_background" = "#${base00}";
            "tab.inactive_background" = "#${base01}";
            "tab_bar.background" = "#${base01}";
            "text.accent" = "#${base0F}";
            "title_bar.background" = "#${base00}";
            "title_bar.inactive_background" = "#${base00}";

            ### Status
            "conflict" = "#${base09}";
            "conflict.background" = "#${base09}d3";
            "conflict.border" = "#${base09}";

            ### Cursors
            "players" = [
              {
                "cursor" = "#${base05}";
                "background" = "#${base05}40";
                "selection" = "#${base05}20";
              }
            ];

            ### Syntax highlighting
            "syntax" = {
              "_expr".color = "#${base0A}";
              "_id".color = "#${base05}";
              "attribute".color = "#${base05}";
              "boolean".color = "#${base09}";
              "comment".color = "#${base02}";
              "comment.doc".color = "#${base02}";
              "constant".color = "#${base05}";
              "constant.builtin".color = "#${base05}";
              "constructor".color = "#${base0A}";
              "directive".color = "#${base05}";
              "embedded".color = "#${base03}";
              "emphasis".color = "#${base05}";
              "emphasis.strong".color = "#${base05}";
              "enum".color = "#${base0A}";
              "escape".color = "#${base09}";
              "function".color = "#${base0D}";
              "function.builtin".color = "#${base0D}";
              "function.call".color = "#${base0D}";
              "function.decorator".color = "#${base0D}";
              "function.magic".color = "#${base0D}";
              "hint".color = "#${base03}";
              "keyword".color = "#${base0F}";
              "keyword.exception".color = "#${base0F}";
              "label".color = "#${base05}";
              "link_text".color = "#${base05}";
              "link_uri".color = "#${base05}";
              "local".color = "#${base05}";
              "markup".color = "#${base05}";
              "meta".color = "#${base05}";
              "modifier".color = "#${base05}";
              "namespace".color = "#${base05}";
              "number".color = "#${base0C}";
              "operator".color = "#${base03}";
              "parameter".color = "#${base0E}";
              "predictive".color = "#${base03}";
              "preproc".color = "#${base05}";
              "primary".color = "#${base05}";
              "property".color = "#${base05}";
              "punctuation".color = "#${base03}";
              "punctuation.bracket".color = "#${base03}";
              "punctuation.delimiter".color = "#${base03}";
              "punctuation.list_marker".color = "#${base03}";
              "punctuation.special".color = "#${base03}";
              "regexp".color = "#${base09}";
              "self".color = "#${base05}";
              "string".color = "#${base0B}";
              "string.escape".color = "#${base09}";
              "string.regex".color = "#${base09}";
              "string.special".color = "#${base09}";
              "string.special.symbol".color = "#${base09}";
              "strong".color = "#${base05}";
              "support".color = "#${base05}";
              "symbol".color = "#${base05}";
              "tag".color = "#${base05}";
              "tag.doctype".color = "#${base05}";
              "text".color = "#${base05}";
              "text.literal".color = "#${base05}";
              "title".color = "#${base05}";
              "type".color = "#${base0A}";
              "variable".color = "#${base05}";
              "variable.member".color = "#${base05}";
              "variable.parameter".color = "#${base0E}";
              "variable.special".color = "#${base05}";
              "variant".color = "#${base05}";
            };
          };
        };
      };

      # HACK: Delete mutable config files to enforce module settings
      # https://github.com/nix-community/home-manager/pull/6993
      home.activation = {
        enforce-zed-editor-config = hm.lib.dag.entryAfter ["writeBoundary"] ''
          run rm --force \
            "$XDG_CONFIG_HOME/zed/settings.json" \
            "$XDG_CONFIG_HOME/zed/keymap.json"
        '';
      };

      # https://zed.dev/docs/snippets
      #?? snippets: configure snippets
      xdg.configFile = {
        "zed/snippets/".source = ./snippets;
      };

      # https://nix-community.github.io/stylix/options/modules/zed.html
      stylix.targets.zed.enable = true;
    };
  };
}
