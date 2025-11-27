#! /usr/bin/env bash

cd /etc/nixos || exit 1

# @describe Wrapper for NixOS tools
# Assumes flakes and configuration in /etc/nixos/
#
# https://github.com/sigoden/argc
# https://github.com/jorsn/flakegen
# https://github.com/viperML/nh

# @meta combine-shorts
# @meta inherit-flag-options

# @cmd Build NixOS configuration
# @alias b,bu,bui,buil
# @option -b --builder[=nh|nixos] Use nh os (default) or nixos-rebuild to build
# @option -t --target Remote machine to build with root, only nixos-rebuild is supported
# @flag -n --no-generate Do not regenerate flake.nix before building
# @flag -p --poweroff Gracefully poweroff system after a successful build
# @flag -r --reboot Gracefully reboot system after a successful build
# @flag -u --update Update flake.lock before building
build() { :; }

# Internal wrapper for subcommands
_build() {
  # Regenerate flake.nix and stage git files by default
  if [[ ! "${argc_no_generate:-}" ]]; then
    nix run .#genflake flake.nix
    git add .
  fi

  # Update flake.lock
  if [[ "${argc_update:-}" ]]; then
    nix flake update
  fi

  # Build current system
  if [[ "${argc_builder:-}" == nh ]]; then
    if [[ "${argc_target:-}" ]]; then
      # Build and send closures to remote machine
      nh os "$1" --hostname "${argc_target}" --target-host "root@${argc_target}" -- --show-trace ${argc_extra:+"${argc_extra[@]}"}
    else
      # Build local machine
      nh os "$1" -- --show-trace ${argc_extra:+"${argc_extra[@]}"}
    fi
  elif [[ "${argc_builder:-}" == nixos ]]; then
    if [[ "${argc_target:-}" ]]; then
      # Build and send closures to remote machine
      nixos-rebuild --flake ".#${argc_target}" --target-host "root@${argc_target}" "$1" --show-trace ${argc_extra:+"${argc_extra[@]}"}
    else
      # Build local machine
      sudo nixos-rebuild "$1" --show-trace ${argc_extra:+"${argc_extra[@]}"}
    fi
  fi

  # Use systemd to act on system
  # Assumes errexit shell option is set
  if [[ "${argc_poweroff:-}" ]]; then
    action=(systemctl poweroff)
  elif [[ "${argc_reboot:-}" ]]; then
    action=(systemctl reboot)
  fi

  # Invoke action on remote target if specified
  if [[ -v action ]]; then
    if [[ "${argc_target:-}" ]]; then
      # shellcheck disable=SC2029
      ssh root@"${argc_target}" "${action[@]}"
    else
      sudo "${action[@]}"
    fi
  fi
}

# @cmd Build and boot NixOS configuration
# @alias b,bo,boo
# @arg extra~ Pass extra arguments to builder
build::boot() { _build boot; }

# @cmd Build and switch NixOS configuration
# @alias s,sw,swi,swit,switc
# @arg extra~ Pass extra arguments to builder
build::switch() { _build switch; }

# @cmd Build and test NixOS configuration
# @alias t,te,tes
# @arg extra~ Pass extra arguments to builder
build::test() { _build test; }

# @cmd Compare NixOS system generations
# @alias d,di,dif
# @arg path1=/run/current-system Store path to compare with (current system by default)
# @arg path2=/nix/var/nix/profiles/system Store path to compare against (built system by default)
diff() {
  nvd diff "${argc_path1:-}" "${argc_path2:-}"
}

# @cmd Generate flake.nix from flake.in.nix with flakegen
# @alias g,ge,gen,gene,gener,genera,generat
# @flag -n --nuke Delete flake.nix and reinitialize
generate() {
  if [[ "${argc_nuke:-}" ]]; then
    rm --force flake.nix
    nix flake init --template github:myned/flakegen
  fi

  nix run .#genflake flake.nix
  git add .
}

# @cmd List NixOS generations
# @alias l,li,lis
# @arg extra~ Pass extra arguments to nixos-rebuild
list() {
  nixos-rebuild list-generations ${argc_extra:+"${argc_extra[@]}"}
}

# @cmd Enter an interactive NixOS read-eval-print loop with the current configuration
# @alias r,re,rep
# @flag -n --no-generate Do not regenerate flake.nix before entering loop
# @arg extra~ Pass extra arguments to nixos-rebuild
repl() {
  if [[ ! "${argc_no_generate:-}" ]]; then
    nix run .#genflake flake.nix
    git add .
  fi

  nixos-rebuild repl ${argc_extra:+"${argc_extra[@]}"}
}

eval "$(argc --argc-eval "$0" "$@")"
