# Sh-Menu-Using-YAML/JSON

This project provides a simple, highly modular, and extensible command-line interface built using a Bash script. The script dynamically reads commands from either a JSON or YAML configuration file. Users can easily execute common operations through a straightforward menu by passing the configuration files as arguments to the menu.sh script. The index.html is used for the quick generation of json/yaml config files for the script.

## Files

- `menu.sh`: The main Bash script that displays the menu and executes commands based on user selection.
- `options.json`: An example configuration file containing command names and associated commands (in JSON format).
- `options.yaml`: An example configuration file containing command names and associated commands (in YAML format).
- `index.html`: A webui designed to streamline the creation of json and yaml files for this script.

## Getting Started

### Prerequisites

Ensure you have the following installed:
- `bash`
- `jq`: A command-line JSON processor (can be installed using your package manager).
- `yq`: A command-line YAML processor (can be installed using your package manager).
-  `A Web Browser`: A web browser. (Not tested on text-based web-browsers.)

## Usage

Start by opening the index.html file in your web-browser. Fill out the form and download the generated code. Run the script by calling
`sh manu.sh <path-to-json/yaml>`.
When the script is running, a menu will be displayed showing the names of commands listed within the provided configuration file. You can select an option by typing its corresponding number, and the associated command will be executed.

## Best Practices for Naming Options in options.yaml
##### The webui automatically formats entries according to best pratices.

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
