{lib, ...}:
with lib; {
  # Import all *.nix options from custom directory, excluding .*.nix
  imports =
    filter (
      file: let
        f = builtins.baseNameOf file;
      in
        !hasPrefix "." f && hasSuffix ".nix" f
    )
    (filesystem.listFilesRecursive ./custom);
}
