#!/usr/bin/env bash

# Define color codes for terminal output
Black='\033[0;30m'     # Black
Red='\033[0;31m'       # Red
Green='\033[0;32m'     # Green
Yellow='\033[0;33m'    # Yellow
Blue='\033[0;34m'      # Blue
Purple='\033[0;35m'    # Purple
Cyan='\033[0;36m'      # Cyan
White='\033[0;37m'     # White
Neutral='\033[0m'      # Reset color to default
Color1="$Purple"       # Assign Purple to Color1
Color2="$Green"        # Assign Green to Color2

# Function to display a banner with a message
banner() {
    msg="# $* #"  # Format message with padding
    edge=$(echo "$msg" | sed 's/./#/g')  # Create a border with '#' characters
    printf "$Color1$edge$Neutral\n"  # Print top edge in Color1
    echo "$msg"  # Print the message itself
    printf "$Color2$edge$Neutral\n"  # Print bottom edge in Color2
}

# Function to display help information
Help() {
   # Display Help
   echo
   banner "Add description of the script functions here."  # Banner for the help section
   echo
   printf $Color1"Syntax:$Neutral scriptTemplate [-g|h|v|V]\n"  # Show syntax
   echo
   banner "Options:"  # Banner for options section
   echo
   printf $Color1"-g$Neutral)     Print the GPL license notification.\n"  # Description for '-g'
   printf $Color2"-h$Neutral)     Print this Help.\n"  # Description for '-h'
   printf $Color1"-v$Neutral)     Verbose mode.\n"  # Description for '-v'
   printf $Color2"-V$Neutral)     Print software version and exit.\n"  # Description for '-V'
   echo
}

# Function to print the GPL license
GPL() {
   echo "GPL License here"  # Placeholder for the actual GPL license text
}

# Function for verbose mode
Verbose() {
   echo "This should exit 0"  # Placeholder message for verbose output
}

# Function to print version information
Version() {
   echo "This should exit 1"  # Placeholder message for version info
}

# Check if no arguments were given
if [ -z "$@" ] ; then
  echo "Needs args"  # Notify user that arguments are required
  exit 1  # Exit with an error code
fi

# Main loop to process command-line options
while getopts ":hgvV" option; do
   case $option in
      h) Help     # Display help information
         exit ;;  # Exit after displaying help
      g) GPL      # Print the GPL license notification
         exit ;;  # Exit after displaying the GPL
      v) Verbose   # Activate verbose mode
         exit 0 ;; # Exit successfully after verbose
      V) Version   # Print version information
         exit 1 ;; # Exit with an error code for version info
      \?)          # Handle invalid options
         echo "Invalid option: -$OPTARG"  # Notify user of invalid option
         Help      # Display help for proper usage
         exit ;;   # Exit after displaying help
   esac
done

# If we reached this point, it means no supported options were provided
echo "No valid options provided. Use -h for help."  # Notify user to use help option
