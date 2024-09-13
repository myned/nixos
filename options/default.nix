{lib, ...}:
with lib; {
  # Import all *.nix options from custom directory
  imports = filter (f: strings.hasSuffix ".nix" f) (filesystem.listFilesRecursive ./custom);
}
