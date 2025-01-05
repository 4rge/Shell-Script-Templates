#!/bin/bash

# Function to display the menu
display_menu() {
    clear
    echo "Main Menu"
    echo "=================="
    local count=1
    # Loop to construct the menu from the YAML file
    option_names=($(yq -r '.options[] | .name' options.yaml))

    for option in "${option_names[@]}"; do
        echo "$count.) $option"
        count=$((count + 1))
    done
    echo "0.) Exit"
}

# Function to execute the selected command
execute_command() {
    local command=$(yq -r ".options[$1].command" options.yaml)
    echo "Executing: $command"
    eval "$command"
    read -p "Press [Enter] to continue..."
}

# Main loop
while true; do
    display_menu
    read -p "Select an option: " choice

    case $choice in
        [0-9]) 
            if [[ "$choice" -eq 0 ]]; then
                exit 0
            elif [[ "$choice" -gt 0 ]]; then
                option_index=$((choice - 1))
                total_options=$(yq -r '.options | length' options.yaml)
                if [[ "$option_index" -lt "$total_options" ]]; then
                    execute_command $option_index
                else
                    echo "Invalid option."
                fi
            fi
            ;;
        *)
            echo "Invalid option, please try again."
            read -p "Press [Enter] to continue..."
            ;;
    esac
done
