#!/usr/bin/env fish
# sudo nix --experimental-features 'nix-command flakes' run nixpkgs#fish -- install.fish

# Wrap command execution in log output with error handling
function execute
    if $argv &>>install.log
        echo " done."
    else
        echo " error."
        exit 1
    end
end

# Alias nix to enable flakes
alias nix "nix --experimental-features 'nix-command flakes'"

# Gather variables
set -l machine (read -P "Enter machine hostname: ")
set -l secret (read -P "Enter encryption secret: ")

# Clear logfile
echo "Logging to install.log..."
rm install.log &>/dev/null

# Create keyfile
echo -n "Creating secret.key..."
execute nix run nixpkgs#fish -- -c "echo -n $secret > /tmp/secret.key"

# Format disks
echo -n "Formatting disks..."
execute nix run disko -- -m disko machines/$machine/disko.nix

# Shred keyfile
echo -n "Shredding secret.key..."
execute shred -zu /tmp/secret.key

# Generate hardware configuration
echo -n "Generating hardware-configuration.nix..."
execute nixos-generate-config --no-filesystems --root /mnt --dir .

# Move hardware configuration
echo -n "Moving hardware-configuration.nix to machines/$machine/..."
execute mv hardware-configuration.nix machines/$machine/

# Stage files in git tree for flake to access
git add .

# Update flake
echo -n "Updating flake.lock..."
execute nix flake update

# Confirm installation of NixOS
while true
    switch (read -P "Install NixOS? [Y/N] ")
        case Y y
            break
        case N n
            exit
    end
end

# Install NixOS
echo -n "Installing..."
execute nixos-install --no-root-password --flake .#$machine

# Update git remote to remove personal access token
echo -n "Updating git remotes..."
git remote rm origin
execute git remote add git@github.com/Myned/nixos.git

# Copy NixOS configuration to system
echo -n "Copying NixOS configuration to /mnt/etc/nixos/..."
execute cp -r . /mnt/etc/nixos/

# Finish
echo "Installation finished. Reboot when ready."
