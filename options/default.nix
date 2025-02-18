{lib, ...}:
with lib; {
  # Import all *.nix options from custom directory, excluding .*.nix
  imports = filter (f: hasSuffix ".nix" f && !hasPrefix "." (builtins.baseNameOf f)) (filesystem.listFilesRecursive ./custom);
}
