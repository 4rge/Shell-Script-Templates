#!/usr/bin/env/ bash

Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
Purple='\033[0;35m'
Cyan='\033[0;36m'
White='\033[0;37m'
Neutral='\033[0m'
Color1="$Purple"
Color2="$Green"

banner() {
    msg="# $* #"
    edge=$(echo "$msg" | sed 's/./#/g')
    printf "$Color1$edge$Neutral\n"
    echo "$msg"
    printf "$Color2$edge$Neutral\n"
}

Help() {
   # Display Help
   echo
   banner "Add description of the script functions here."
   echo
   printf $Color1"Syntax:$Neutral scriptTemplate [-g|h|v|V]\n"
   echo
   banner "Options:"
   echo
   printf $Color1"-g$Neutral)     Print the GPL license notification.\n"
   printf $Color2"-h$Neutral)     Print this Help.\n"
   printf $Color1"-v$Neutral)     Verbose mode.\n"
   printf $Color2"-V$Neutral)     Print software version and exit.\n"
   echo
}

GPL() {
   echo "GPL License here"
}

Verbose() {
   echo "This should exit 0"
}

Version() {
   echo "This should exit 1"
}

if [ -z "$@" ] ; then
  echo "Needs args"
fi

while getopts ":hgvV" option; do
   case $option in
      h) Help
         exit ;;
      g) GPL
         exit ;;
      v) Verbose
         exit 0 ;;
      V) Version
         exit 1 ;;
   esac
done
