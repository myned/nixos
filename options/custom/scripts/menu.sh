#! /usr/bin/env bash

# Menu wrapper
#?? menu

command=walker

while (("$#" > 0)); do
  case "$1" in
    --applications)
      command="walker --modules applications"
      ;;
    --calculator)
      command="walker --modules calc"
      ;;
    --clipboard)
      command="walker --modules clipboard"
      ;;
    --files)
      command="walker --modules finder"
      ;;
    --input)
      command="walker --dmenu"
      ;;
    --networks)
      command="networkmanager_dmenu"
      ;;
    --passwords)
      command="rofi-rbw"
      ;;
    --runner)
      command="walker --modules runner"
      ;;
    --search)
      command="walker --modules websearch"
      ;;
    --ssh)
      command="walker --modules ssh"
      ;;
    --unicode)
      command="walker --modules emojis"
      ;;
    --windows)
      command="walker --modules windows"
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
