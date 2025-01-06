#!/bin/bash

# Define default color codes
declare -A color_codes=(
    ["cyan"]="\e[36m"
    ["yellow"]="\e[33m"
    ["red"]="\e[31m"
    ["green"]="\e[32m"
    ["reset"]="\e[0m"
)

# Initialize colors with default values
COLOR_HEADER=${color_codes["cyan"]}
COLOR_OPTION=${color_codes["yellow"]}
COLOR_ERROR=${color_codes["red"]}
COLOR_COMMAND=${color_codes["green"]}
COLOR_RESET=${color_codes["reset"]}

# Function to set colors from the configuration file
set_colors_from_config() {
    if [[ "$1" == *.json ]]; then
        local colors=$(jq -r '.colors' "$1")
    elif [[ "$1" == *.yaml || "$1" == *.yml ]]; then
        local colors=$(yq -r '.colors' "$1")
    else
        return
    fi

    if [[ $? -eq 0 ]]; then
        COLOR_HEADER=${color_codes["$(echo "$colors" | jq -r '.header' || yq -r '.header')"]} || COLOR_HEADER
        COLOR_OPTION=${color_codes["$(echo "$colors" | jq -r '.option' || yq -r '.option')"]} || COLOR_OPTION
        COLOR_ERROR=${color_codes["$(echo "$colors" | jq -r '.error' || yq -r '.error')"]} || COLOR_ERROR
        COLOR_COMMAND=${color_codes["$(echo "$colors" | jq -r '.command' || yq -r '.command')"]} || COLOR_COMMAND
    fi
}

# Function to display the menu
display_menu() {
    clear
    echo -e "${COLOR_HEADER}=========================${COLOR_RESET}"
    echo -e "${COLOR_HEADER}        Main Menu        ${COLOR_RESET}"
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
    echo -e "${COLOR_ERROR}0.) Exit${COLOR_RESET}"
    echo -e "${COLOR_HEADER}=========================${COLOR_RESET}"
}

# Function to execute the selected command
execute_command() {
    local command

    # Retrieve the command based on the selected option
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

    # Replace placeholders in angle brackets with user input
    while [[ "$command" =~ \<([a-zA-Z0-9_]+)\> ]]; do
        placeholder="${BASH_REMATCH[0]}"            # Full placeholder including <>
        key="${BASH_REMATCH[1]}"                    # Placeholder name without <>
        read -p "Please enter the value for $key: " user_input
        command=${command//$placeholder/$user_input}  # Replace with user input
    done

    # Before executing, check if the command is not empty
    if [[ -z "$command" ]]; then
        echo -e "${COLOR_ERROR}Error: The command to execute is empty.${COLOR_RESET}"
        exit 1
    fi

    echo -e "${COLOR_COMMAND}Executing: $command${COLOR_RESET}"
    eval "$command" || {
        echo -e "${COLOR_ERROR}Error executing command: $command${COLOR_RESET}"
        exit 1
    }
    read -p "Press [Enter] to continue..."
}

# Ensure a file is passed as an argument
if [ "$#" -ne 1 ]; then
    echo -e "${COLOR_ERROR}Usage: $0 <options.json|options.yaml>${COLOR_RESET}"
    exit 1
fi

# Load colors from the configuration file
set_colors_from_config "$1"

# Main loop
while true; do
    display_menu "$1"
    read -p "Select an option: " choice

    if [[ "$choice" =~ ^[0-9]+$ ]]; then 
        if [[ "$choice" -eq 0 ]]; then
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
