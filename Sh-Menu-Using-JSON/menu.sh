#!/bin/bash

# Function to display the menu
display_menu() {
    clear
    echo "Main Menu"
    echo "=================="
    local count=1
    local option_names

    # Check if the JSON or YAML file exists
    if [[ ! -f "$1" ]]; then
        echo "Error: File '$1' not found."
        exit 1
    fi

    # Determine file type and parse accordingly
    if [[ "$1" == *.json ]]; then
        option_names=($(jq -r '.options[].name' "$1" 2>&1))
    elif [[ "$1" == *.yaml || "$1" == *.yml ]]; then
        option_names=($(yq -r '.options[].name' "$1" 2>&1))
    else
        echo "Error: Unsupported file format. Please provide a JSON or YAML file."
        exit 1
    fi

    # Check if the parsing was successful
    if [[ $? -ne 0 ]]; then
        echo "Error while parsing file: $option_names"
        exit 1
    fi

    # Display options
    for option in "${option_names[@]}"; do
        echo "$count.) $option"
        count=$((count + 1))
    done
    echo "0.) Exit"
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
        echo "Error while retrieving command: $command"
        exit 1
    fi
    
    echo "Executing: $command"
    eval "$command"
    read -p "Press [Enter] to continue..."
}

# Ensure a file is passed as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <options.json|options.yaml>"
    exit 1
fi

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
                echo "Error fetching total options."
                exit 1
            fi
            
            if [[ "$option_index" -lt "$total_options" ]]; then
                execute_command "$option_index" "$1"
            else
                echo "Invalid option."
            fi
        fi
    else
        echo "Invalid option, please try again."
        read -p "Press [Enter] to continue..."
    fi
done
