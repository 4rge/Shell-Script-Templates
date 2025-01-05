# Sh-Menu-Using-YAML

This project provides a simple, highly modular and extensible command-line interface. Built using a Bash script that dynamically reads commands from a YAML configuration file. Users can easily execute common operations through a straightforward menu.

## Files

- `menu.sh`: The main Bash script that displays the menu and executes commands based on user selection.
- `options.yaml`: The configuration file containing the command names and associated commands. (Note: Templates available in the YAML-Options-Templates folder.)

## Getting Started

### Prerequisites

Ensure you have the following installed:
- `bash`
- `yq`: A command-line YAML processor (can be installed using your package manager).

## Usage
When the script is run, a menu will be displayed showing the names of commands listed in the yaml file. You can select an option by typing its corresponding number, and the associated command will be executed. The default options.yaml contains various examples.

## Best Practices for Naming Options in options.yaml

### Single Word or Hyphenated:
All names in the options.yaml file should be a single word or use hyphens to separate words (e.g., Install-Package).
Avoid using spaces or special characters in names to ensure compatibility and correct parsing.

### Descriptive Names:
Use names that clearly describe the action performed by the command (e.g., Update for updating the system).
This will make the menu intuitive and user-friendly.

### Consistent Naming Convention:
Decide on a consistent naming convention (e.g., use camel case, underscores, or hyphens) and stick to it throughout the file.

## Contributing

Contributions are welcome! If you'd like to contribute to this project, please follow these guidelines:

Fork the Repository: Start by forking the repository to your own GitHub account.
Create a New Feature Branch: For example:
git checkout -b feature/my-new-feature

Make Your Changes: Implement your feature or bugfix.
Update Documentation: If applicable, update the README file and options.yaml to reflect the changes.
Commit Your Changes: Only commit changes to files you worked on:
git commit -m "Add a descriptive message for your changes"

Push to Your Feature Branch:
git push origin feature/my-new-feature

Create a Pull Request:
On GitHub, navigate to the "Pull Requests" page and create a new pull request.

Thank you for considering contributing! Your help is appreciated.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
