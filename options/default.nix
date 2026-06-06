{lib, ...}:
with lib; {
  # Import all *.nix options from custom directory, excluding .*.nix and .*/
  imports =
    filter (
      file: let
        basename = builtins.baseNameOf file;
        excludeHiddenNix = !hasPrefix "." basename && hasSuffix ".nix" basename;
        excludeHiddenDirs = all (path: !hasPrefix "." path) (splitString "/" file);
      in
        excludeHiddenNix && excludeHiddenDirs
    )
    (filesystem.listFilesRecursive ./custom);
}
