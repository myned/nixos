#! /usr/bin/env bash

# @describe Wrapper for menu commands
#
# https://github.com/sigoden/argc

# @meta combine-shorts

# HACK: Restart service to close existing menu
if hyprctl -j layers | jq -e '.[][][][] | select(.namespace == "walker")'; then
  systemctl --user restart walker.service
  exit
fi

# @cmd Launch menu without modules
# @meta default-subcommand
menu() {
  walker
}

# @cmd Launch menu with application module
# @alias a,ap,app,appl,appli,applic,applica,applicat,applicati,applicatio,applications
application() {
  walker --modules applications
}

# @cmd Launch menu with calculator module
# @alias c,ca,calc,calcu,calcul,calcula,calculat,calculato
calculator() {
  walker --modules calc
}

# @cmd Launch menu with clipboard module
# @alias cl,cli,clip,clipb,clipbo,clipboa,clipboar
clipboard() {
  walker --modules clipboard
}

# @cmd Launch menu with emoji module
# @alias e,em,emo,emoj,emot,emote
emoji() {
  walker --modules emojis
}

# @cmd Launch menu with file module
# @alias f,fi,fil,files
file() {
  walker --modules finder
}

# @cmd Launch menu with input module
# @alias i,in,inp,inpu,d,dm,dme,dmen,dmenu
input() {
  walker --dmenu
}

# @cmd Launch menu via networkmanager_dmenu
# @alias n,ne,net,netw,netwo,networks
network() {
  networkmanager_dmenu
}

# @cmd Launch menu via rofi-rbw
# @alias p,pa,pas,pass,passw,passwo,passwor,passwords
password() {
  rofi-rbw
}

# @cmd Launch menu with search module
# @alias s,se,sea,sear,searc
search() {
  walker --modules search
}

# @cmd Launch menu with shell module
# @alias sh,she,shel,co,com,comm,comma,comman,command,commands
shell() {
  walker --modules runner
}

# @cmd Launch menu with ssh module
# @alias ss
ssh() {
  walker --modules ssh
}

# @cmd Launch menu with wm module
# @alias w,wi,win,wind,windo,window,windows
wm() {
  walker --modules windows
}

eval "$(argc --argc-eval "$0" "$@")"
