# Sh-Menu-Using-YAML/JSON

This project provides a simple, highly modular, and extensible command-line interface built using a Bash script. The script dynamically reads commands from either a JSON or YAML configuration file. Users can easily execute common operations through a straightforward menu by passing the configuration files as arguments to the menu.sh script.

## Files

- `menu.sh`: The main Bash script that displays the menu and executes commands based on user selection.
- `options.json`: An example configuration file containing command names and associated commands (in JSON format).
- `options.yaml`: An example configuration file containing command names and associated commands (in YAML format).

## Getting Started

### Prerequisites

Ensure you have the following installed:
- `bash`
- `jq`: A command-line JSON processor (can be installed using your package manager).
- `yq`: A command-line YAML processor (can be installed using your package manager).

## Usage

When the script is run, a menu will be displayed showing the names of commands listed within the provided configuration file (either JSON or YAML). You can select an option by typing its corresponding number, and the associated command will be executed.

### Examples: 
`sh menu.sh your-menu.json`
`sh menu.sh your-menu.yaml`

## Best Practices for Naming Options in options.yaml

### Single Word or Hyphenated:
All names in the options.json file should be a single word or use hyphens to separate words (e.g., Install-Package).
Avoid using spaces or special characters in names to ensure compatibility and correct parsing.

### Descriptive Names:
Use names that clearly describe the action performed by the command (e.g., Update for updating the system).
This will make the menu intuitive and user-friendly.

### Consistent Naming Convention:
Decide on a consistent naming convention (e.g., use camel case, underscores, or hyphens) and stick to it throughout the file.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
