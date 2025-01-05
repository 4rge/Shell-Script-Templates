#!/usr/bin/env python3

import argparse
import sys

# ANSI color codes for terminal output
BLACK = '\033[0;30m'
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[0;33m'
BLUE = '\033[0;34m'
PURPLE = '\033[0;35m'
CYAN = '\033[0;36m'
WHITE = '\033[0;37m'
NEUTRAL = '\033[0m'
COLOR1 = PURPLE
COLOR2 = GREEN

def banner(msg):
    """Prints a decorative banner with the message."""
    msg = f"# {msg} #"
    edge = "#" * len(msg)  # Create a border using '#'
    print(f"{COLOR1}{edge}{NEUTRAL}")  # Top edge in COLOR1
    print(msg)  # Message
    print(f"{COLOR2}{edge}{NEUTRAL}")  # Bottom edge in COLOR2

def help_message():
    """Displays help information about the script and its options."""
    print()
    banner("Add description of the script functions here.")
    print()
    print(f"{COLOR1}Syntax:{NEUTRAL} scriptTemplate [-g|h|v|V]")
    print()
    banner("Options:")
    print()
    print(f"{COLOR1}-g{NEUTRAL})     Print the GPL license notification.")
    print(f"{COLOR2}-h{NEUTRAL})     Print this Help.")
    print(f"{COLOR1}-v{NEUTRAL})     Verbose mode.")
    print(f"{COLOR2}-V{NEUTRAL})     Print software version and exit.")
    print()

def gpl():
    """Displays the GPL license information."""
    print("GPL License here")

def verbose():
    """Displays a message indicating verbose mode has been activated."""
    print("This should exit 0")

def version():
    """Displays the version of the software."""
    print("This should exit 1")

def main():
    """Main function to handle command line arguments and program logic."""
    parser = argparse.ArgumentParser(description='Script template')
    
    # Define command line options
    parser.add_argument('-g', action='store_true', help='Print the GPL license notification.')
    parser.add_argument('-h', action='store_true', help='Print help message.')
    parser.add_argument('-v', action='store_true', help='Verbose mode.')
    parser.add_argument('-V', action='store_true', help='Print software version and exit.')

    args = parser.parse_args()  # Parse command line arguments

    # Check if no arguments were supplied
    if not any(vars(args).values()):
        print("Needs args")
        sys.exit(1)

    # Handle the various command line options
    if args.h:
        help_message()
        sys.exit()

    if args.g:
        gpl()
        sys.exit()

    if args.v:
        verbose()
        sys.exit(0)

    if args.V:
        version()
        sys.exit(1)

if __name__ == "__main__":
    while True:
        try:
            # Call the main function to process command line arguments
            main()
            break  # Exit loop if main function succeeds
        except KeyboardInterrupt:
            print("\nExiting the program. Goodbye!")
            sys.exit(0)
