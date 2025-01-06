#!/bin/bash

# Define default color codes
declare -A color_codes=(
    ["cyan"]="\e[36m"
    ["yellow"]="\e[33m"
    ["red"]="\e[31m"
    ["green"]="\e[32m"
    ["reset"]="\e[0m"
)

# Initialize colors and other settings with default values
COLOR_HEADER=${color_codes["cyan"]}
COLOR_OPTION=${color_codes["yellow"]}
COLOR_ERROR=${color_codes["red"]}
COLOR_COMMAND=${color_codes["green"]}
COLOR_RESET=${color_codes["reset"]}

MENU_TITLE="Main Menu"
FOOTER_MESSAGE=""
DEFAULT_OPTION=-1
INPUT_PROMPT="Select an option:"
ALLOW_EXIT=true
HELP_COMMAND=""
CONFIRM_EXECUTION=false
LOG_FILE=""

# Function to set colors and settings from the configuration file
set_config_from_file() {
    if [[ "$1" == *.json ]]; then
        MENU_TITLE=$(jq -r '.menuTitle // "Main Menu"' "$1")
        FOOTER_MESSAGE=$(jq -r '.footerMessage // ""' "$1")
        color_settings=$(jq -r '.colors' "$1")
    elif [[ "$1" == *.yaml || "$1" == *.yml ]]; then
        MENU_TITLE=$(yq -r '.menuTitle // "Main Menu"' "$1")
        FOOTER_MESSAGE=$(yq -r '.footerMessage // ""' "$1")
        color_settings=$(yq -r '.colors' "$1")
    else
        return
    fi

    # Set color variables
    COLOR_HEADER=${color_codes["$(echo "$color_settings" | jq -r '.header' || yq -r '.header')"]} || COLOR_HEADER
    COLOR_OPTION=${color_codes["$(echo "$color_settings" | jq -r '.option' || yq -r '.option')"]} || COLOR_OPTION
    COLOR_ERROR=${color_codes["$(echo "$color_settings" | jq -r '.error' || yq -r '.error')"]} || COLOR_ERROR
    COLOR_COMMAND=${color_codes["$(echo "$color_settings" | jq -r '.command' || yq -r '.command')"]} || COLOR_COMMAND

    DEFAULT_OPTION=$(jq -r '.defaultOption // -1' "$1")
    INPUT_PROMPT=$(jq -r '.inputPrompt // "Select an option:"' "$1")
    ALLOW_EXIT=$(jq -r '.allowExit // true' "$1")
    HELP_COMMAND=$(jq -r '.helpCommand // ""' "$1")
    CONFIRM_EXECUTION=$(jq -r '.confirmExecution // false' "$1")
    LOG_FILE=$(jq -r '.logFile // ""' "$1")
}

# Function to display the menu
display_menu() {
    clear
    echo -e "${COLOR_HEADER}=========================${COLOR_RESET}"
    echo -e "${COLOR_HEADER}        $MENU_TITLE        ${COLOR_RESET}"
    echo -e "${COLOR_HEADER}=========================${COLOR_RESET}"
    local count=1
    local option_names

    # Check if the JSON or YAML file exists
    if [[ ! -f "$1" ]]; then
        echo -e "${COLOR_ERROR}Error: File '$1' not found.${COLOR_RESET}"
        exit 1
    fi

    # Determine file type and parse accordingly
    if [[ "$1" == *.json ]]; then
        option_names=($(jq -r '.options[].name' "$1" 2>&1))
    elif [[ "$1" == *.yaml || "$1" == *.yml ]]; then
        option_names=($(yq -r '.options[].name' "$1" 2>&1))
    else
        echo -e "${COLOR_ERROR}Error: Unsupported file format. Please provide a JSON or YAML file.${COLOR_RESET}"
        exit 1
    fi

    # Check if the parsing was successful
    if [[ $? -ne 0 ]]; then
        echo -e "${COLOR_ERROR}Error while parsing file: $option_names${COLOR_RESET}"
        exit 1
    fi

    # Display options
    for option in "${option_names[@]}"; do
        echo -e "${COLOR_OPTION}→ $count.) $option${COLOR_RESET}"
        count=$((count + 1))
    done

    if [ "$ALLOW_EXIT" = true ]; then
        echo -e "${COLOR_ERROR}0.) Exit${COLOR_RESET}"
    fi

    echo -e "${COLOR_HEADER}=========================${COLOR_RESET}"
    if [ ! -z "$FOOTER_MESSAGE" ]; then
        echo -e "${COLOR_CYAN}$FOOTER_MESSAGE${COLOR_RESET}"
    fi
}

# Function to execute the selected command
execute_command() {
    local command

    # Determine file type and parse accordingly
    if [[ "$2" == *.json ]]; then
        command=$(jq -r ".options[$1].command" "$2" 2>&1)
    elif [[ "$2" == *.yaml || "$2" == *.yml ]]; then
        command=$(yq -r ".options[$1].command" "$2" 2>&1)
    fi

    # Check if the command retrieval was successful
    if [[ $? -ne 0 ]]; then
        echo -e "${COLOR_ERROR}Error while retrieving command: $command${COLOR_RESET}"
        exit 1
    fi

    if [ "$CONFIRM_EXECUTION" = true ]; then
        read -p "Are you sure you want to execute: $command? (y/n): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "${COLOR_ERROR}Command execution canceled.${COLOR_RESET}"
            return
        fi
    fi
    
    echo -e "${COLOR_COMMAND}Executing: $command${COLOR_RESET}"
    eval "$command"
    
    # Log the executed command if a log file is specified
    if [[ ! -z "$LOG_FILE" ]]; then
        echo "Executed Command: $command" >> "$LOG_FILE"
    fi
    
    read -p "Press [Enter] to continue..."
}

# Ensure a file is passed as an argument
if [ "$#" -ne 1 ]; then
    echo -e "${COLOR_ERROR}Usage: $0 <options.json|options.yaml>${COLOR_RESET}"
    exit 1
fi

# Load configuration from the file
set_config_from_file "$1"

# Main loop
while true; do
    display_menu "$1"
    read -p "$INPUT_PROMPT " choice

    if [[ "$choice" =~ ^[0-9]+$ ]]; then 
        # Handle exit option if specified
        if [ "$ALLOW_EXIT" = true ] && [[ "$choice" -eq 0 ]]; then
            exit 0
        elif [[ "$choice" -gt 0 ]]; then
            option_index=$((choice - 1))
            
            # Determine file type and fetch total options
            if [[ "$1" == *.json ]]; then
                total_options=$(jq -r '.options | length' "$1")
            elif [[ "$1" == *.yaml || "$1" == *.yml ]]; then
                total_options=$(yq -r '.options | length' "$1")
            fi
            
            if [[ $? -ne 0 ]]; then
                echo -e "${COLOR_ERROR}Error fetching total options.${COLOR_RESET}"
                exit 1
            fi
            
            if [[ "$option_index" -lt "$total_options" ]]; then
                execute_command "$option_index" "$1"
            else
                echo -e "${COLOR_ERROR}Invalid option.${COLOR_RESET}"
            fi
        fi
    else
        echo -e "${COLOR_ERROR}Invalid option, please try again.${COLOR_RESET}"
        read -p "Press [Enter] to continue..."
    fi
done
