# https://bmcgee.ie/posts/2023/03/til-how-to-generate-nixos-module-docs/
{
  lib,
  pkgs,
  ...
}:
with lib; let
  # https://github.com/NixOS/nixpkgs/blob/master/lib/modules.nix
  eval = evalModules {
    check = false; # Exclude option definitions (config)

    modules =
      filter (
        file: let
          f = builtins.baseNameOf file;
        in
          !hasPrefix "." f && hasSuffix ".nix" f
      )
      (filesystem.listFilesRecursive ../options);
  };

  # https://github.com/NixOS/nixpkgs/blob/master/nixos/lib/make-options-doc/default.nix
  optionsDoc = pkgs.nixosOptionsDoc {
    inherit (eval) options;
  };
in
  pkgs.runCommand "options-doc.md" {} ''
    cat ${optionsDoc.optionsCommonMark} >> $out
  ''
