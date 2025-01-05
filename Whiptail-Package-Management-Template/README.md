# Package Management Tool

This repository contains two command-line tools for managing software packages on Debian-based systems and Arch Linux. One tool is a Bash script that utilizes `apt` for package management, while the other is a Python script providing identical functionality.

## Features

- **Menu Interface**: Both tools offer an intuitive menu to choose between installing and purging packages.
- **Package Management**: Facilitates the installation and removal of packages using `apt` (for the Bash script) or a similar approach in the Python script.
- **Progress Feedback**: Displays progress during package operations using a gauge in the Bash script and a console output in the Python script.
- **Cross-Compatibility**: The Bash script can be easily adapted to work with Arch Linux by commenting and uncommenting relevant lines.

## Prerequisites

Before running these tools, ensure you have the following installed:

- A Debian-based Linux distribution (Ubuntu, Debian, etc.).
- `whiptail`: For the graphical interface in the Bash script.
- `apt`: The package manager for Debian GNU/Linux.
- Python (for running the Python script).

## Usage

## Customization

To modify the list of packages managed by either tool, locate the LIST variable. You may add or remove package names as needed, be sure to uncomment the appropriate action for the desired package manager:

`ACTION="install"      # For Debian`
`# ACTION="-Syyu"     # For Arch (uncomment if using Arch)`

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contributing

If you would like to contribute to this project, please fork the repository and submit a pull request with your enhancements or bug fixes.

## Issues

For any issues or feature requests, please raise them in the issues section of the project repository.
