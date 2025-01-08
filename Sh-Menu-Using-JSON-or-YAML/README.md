# Sh-Menu-Using-YAML/JSON

This project provides a simple, highly modular, and extensible command-line interface built using a Bash script. The script dynamically reads commands from either a JSON or YAML configuration file. Users can easily execute common operations through a straightforward menu by passing the configuration files as arguments to the `menu.sh` script.

## Files

- `menu.sh`: The main Bash script that displays the menu and executes commands based on user selection.

## Getting Started

### Prerequisites

Ensure you have the following installed:
- `bash`
- `jq`: A command-line JSON processor (can be installed using your package manager).
- `yq`: A command-line YAML processor (can be installed using your package manager).

## Usage

**Generating a Configuration File**: If you do not have an existing JSON or YAML config file, the script will prompt you to generate a new one. You'll be able to specify the file name, choose between JSON or YAML formats, define colors for the menu, and add multiple options with associated commands.

Run the script by calling:
```bash
sh menu.sh <path-to-json/yaml>

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
