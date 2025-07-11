#! /usr/bin/env bash

# Wrapper to run programs with a blacklisted amdgpu driver

driver="$1"
shift

# Indicate preference for dGPU
export DRI_PRIME=1

# Load driver module
sudo modprobe "$driver"

# Execute wrapped commands in subshell
bash -c "$@" || true

# Warn user about lingering module references
bash -c '
  if [[ $(notify-send -A "Log out" -u critical "> gpurun" "Process exited, click to log out and clear lingering references") ]]; then
    loginctl terminate-user ""
  fi
' &

# Check every two seconds for the module refcount to drop to zero before removing
sudo systemd-run -E PATH -E driver="$driver" -- bash -c '
  while (( $(lsmod | grep "$driver " | tr -s " " | cut -d " " -f 3) > 0 )); do
    sleep 2s
  done

  modprobe --remove "$driver"
'
