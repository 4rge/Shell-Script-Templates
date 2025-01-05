#!/bin/bash

# Function to display the menu
display_menu() {
    clear
    echo "Main Menu"
    echo "=================="
    local count=1
    
    # Check if the JSON file exists
    if [[ ! -f "$1" ]]; then
        echo "Error: JSON file '$1' not found."
        exit 1
    fi

    # Try to fetch option names and capture any jq errors
    option_names=$(jq -r '.options[].name' "$1" 2>&1)

    # Check if jq command succeeded
    if [[ $? -ne 0 ]]; then
        echo "Error while parsing JSON: $option_names"
        exit 1
    fi

    # Prepare the list for the menu
    IFS=$'\n' read -r -d '' -a option_array <<< "$option_names"

    for option in "${option_array[@]}"; do
        echo "$count.) $option"
        count=$((count + 1))
    done
    echo "0.) Exit"
}

# Function to execute the selected command
execute_command() {
    local command=$(jq -r ".options[$1].command" "$2" 2>&1)
    
    # Check if jq command for fetching command succeeded
    if [[ $? -ne 0 ]]; then
        echo "Error while retrieving command: $command"
        exit 1
    fi
    
    echo "Executing: $command"
    eval "$command"
    read -p "Press [Enter] to continue..."
}

# Ensure a JSON file is passed as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <options.json>"
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
            total_options=$(jq -r '.options | length' "$1")
            if [[ $? -ne 0 ]]; then
                echo "Error fetching total options: $total_options"
                exit 1
            fi

            if [[ "$option_index" -lt "$total_options" ]]; then
                execute_command $option_index "$1"
            else
                echo "Invalid option."
            fi
        fi
    else
        echo "Invalid option, please try again."
        read -p "Press [Enter] to continue..."
    fi
done
