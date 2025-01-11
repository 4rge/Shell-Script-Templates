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

# Function to set colors from the configuration XML file
set_colors_from_config() {
    if [[ -f "$1" ]]; then
        COLOR_HEADER=$(xmlstarlet sel -t -v "/settings/colors/header" "$1")
        COLOR_OPTION=$(xmlstarlet sel -t -v "/settings/colors/option" "$1")
        COLOR_ERROR=$(xmlstarlet sel -t -v "/settings/colors/error" "$1")
        COLOR_COMMAND=$(xmlstarlet sel -t -v "/settings/colors/command" "$1")
    else
        return
    fi
}

# Function to create a custom configuration XML file
generate_custom_file() {
    local filename
    filename=$(zenity --entry --title="Custom File" --text="Enter the base name for the XML file (without extension):")
    filename="${filename}.xml"

    # Collect colors
    local header_color=$(zenity --entry --title="Header Color" --text="Enter header color (cyan, yellow, red, green):")
    local option_color=$(zenity --entry --title="Option Color" --text="Enter option color (cyan, yellow, red, green):")
    local error_color=$(zenity --entry --title="Error Color" --text="Enter error color (cyan, yellow, red, green):")
    local command_color=$(zenity --entry --title="Command Color" --text="Enter command color (cyan, yellow, red, green):")

    # Write XML structure
    {
        echo "<settings>"
        echo "    <colors>"
        echo "        <header>$header_color</header>"
        echo "        <option>$option_color</option>"
        echo "        <error>$error_color</error>"
        echo "        <command>$command_color</command>"
        echo "    </colors>"
        echo "    <options>"
    } > "$filename"

    # Add options
    while true; do
        local option_name=$(zenity --entry --title="Option Name" --text="Enter option name (or leave blank to finish):")
        [[ -z "$option_name" ]] && break

        local command=$(zenity --entry --title="Command" --text="Enter command for '$option_name':")

        {
            echo "        <option>"
            echo "            <name>$option_name</name>"
            echo "            <command>$command</command>"
            echo "        </option>"
        } >> "$filename"
    done

    echo "    </options>" >> "$filename"
    echo "</settings>" >> "$filename"

    # Print the XML for debugging
    cat "$filename"
    zenity --info --text="Custom XML file '$filename' created."
}

# Function to display the menu
display_menu() {
    local option_names
    option_names=($(xmlstarlet sel -t -m "/settings/options/option" -v "name" -n "$1"))

    # Check if any options are found
    if [[ -z "$option_names" ]]; then
        zenity --error --text="Error: No options found in file."
        exit 1
    fi

    local menu_options=()
    for option in "${option_names[@]}"; do
        menu_options+=("$option")
    done

    # Use a Zenity list dialog with Cancel as the exit button
    # Escape any special characters that may interfere with Zenity.
    local choice
    choice=$(zenity --list --title="Options" --column="Menu" "${menu_options[@]}" --cancel-label="Exit")

    # Check if the user canceled the dialog
    if [[ $? -ne 0 ]]; then
        return 1  # User pressed Cancel
    fi

    echo "$choice"  # Return the selected choice
}

# Function to execute the selected command
execute_command() {
    local command=$(xmlstarlet sel -t -v "/settings/options/option[name='$1']/command" "$2")

    # Replace placeholders in angle brackets with user input
    while [[ "$command" =~ \<([a-zA-Z0-9_]+)\> ]]; do
        local placeholder="${BASH_REMATCH[0]}" # Full placeholder including <>
        local key="${BASH_REMATCH[1]}" # Placeholder name without <>
        local user_input=$(zenity --entry --title="Input" --text="Please enter the value for $key:")
        command=${command//$placeholder/$user_input} # Replace with user input
    done

    # Before executing, check if the command is not empty
    if [[ -z "$command" ]]; then
        zenity --error --text="Error: The command to execute is empty."
        exit 1
    fi

    echo -e "${COLOR_COMMAND}Executing: $command${COLOR_RESET}"
    eval "$command" || {
        zenity --error --text="Error executing command: $command"
        exit 1
    }
}

# Ensure a file is passed as an argument
if [ "$#" -ne 1 ]; then
    zenity --error --text="Usage: $0 <options.xml>"
    generate_custom_file # Generate custom XML if no file provided
    exit 0
fi

# Load colors from the configuration file
set_colors_from_config "$1"

# Main loop
while true; do
    choice=$(display_menu "$1")

    # Capture exit condition
    if [[ $? -ne 0 ]]; then
        # User pressed the Cancel or Exit button in the menu
        break  # Exit the loop cleanly
    fi

    # Execute the command based on the user selection
    if [[ -n "$choice" ]]; then
        execute_command "$choice" "$1"
    fi
done

# The script exits cleanly
exit 0
