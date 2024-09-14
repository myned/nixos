#! /usr/bin/env bash

# Menu wrapper
#?? menu

command=walker

while (("$#" > 0)); do
  case "$1" in
    -a | --applications)
      command="walker --modules applications"
      ;;
    -c | --calculator)
      command="walker --modules calc"
      ;;
    -f | --files)
      command="walker --modules finder"
      ;;
    -i | --input)
      command="walker --dmenu"
      ;;
    -n | --networks)
      command="networkmanager_dmenu"
      ;;
    -p | --passwords)
      command="rofi-rbw"
      ;;
    -r | --runner)
      command="walker --modules runner"
      ;;
    -s | --ssh)
      command="walker --modules ssh"
      ;;
    -u | --unicode)
      command="walker --modules emojis"
      ;;
    -w | --web)
      command="walker --modules websearch"
      ;;
    --)
      shift
      command+=" $*"
      break
      ;;
  esac
  shift
done

$command
