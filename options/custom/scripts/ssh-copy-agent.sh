#! /usr/bin/env bash

# Match and copy specific ssh agent keys to remote host
#?? ssh-copy-agent <match> ssh://<username>@<hostname>

keys="$(ssh-add -L | grep "$1")"

# ~/.ssh must be 700 or u=rwx
# ~/.ssh/authorized_keys must be 600 or u=rw
# shellcheck disable=SC2029
ssh "$2" "
  umask 077
  mkdir -p ~/.ssh
  umask 177
  touch ~/.ssh/authorized_keys
  echo '$keys' >> ~/.ssh/authorized_keys
"
