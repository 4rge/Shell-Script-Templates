import curses
import subprocess
import time

def execute_command(command):
    """Executes a shell command and returns the result."""
    return subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

def apt_module(stdscr, pkg_list, action):
    """Module to handle apt package management."""
    total_packages = len(pkg_list)
    if total_packages == 0:
        return "No packages specified to install/purge."

    inc = 100 // total_packages
    percentage = 0
    results = []

    for pkg in pkg_list:
        time.sleep(0.5)  # Mimic the sleep in bash
        command = f"sudo apt {action} {pkg} -y"
        stdscr.addstr(5, 0, f"XXX\n{percentage}\n{command}... \nXXX")
        stdscr.refresh()
        
        result = execute_command(command)
        if result.returncode == 0:
            results.append(pkg)
            stdscr.addstr(5, 0, f"XXX\n{percentage + inc}\n{command}... Done.\nXXX")
        else:
            stdscr.addstr(5, 0, f"Error processing {pkg}: {result.stderr.decode('utf-8')}")
        
        stdscr.refresh()
        percentage += inc
        time.sleep(0.5)  # Mimic the sleep in bash

    return f"Successfully {action}ed the following:\n" + "\n".join(results)

def main(stdscr):
    """Main function to run the curses application."""
    curses.curs_set(0)  # Hide the cursor
    stdscr.clear()

    while True:
        stdscr.addstr(0, 0, "Choose an action:")
        stdscr.addstr(1, 2, "1) Install")
        stdscr.addstr(2, 2, "2) Purge")
        stdscr.addstr(4, 0, "Press 'q' to quit.")
        stdscr.refresh()

        key = stdscr.getch()

        if key == ord('1'):
            pkg_list = ["x11-apps", "mc"]
            action = "install"
            result = apt_module(stdscr, pkg_list, action)

        elif key == ord('2'):
            pkg_list = ["x11-apps", "mc"]
            action = "purge"
            result = apt_module(stdscr, pkg_list, action)

        elif key == ord('q'):
            break

        else:
            continue

        # Clear screen and show result
        stdscr.clear()
        stdscr.addstr(0, 0, result)
        stdscr.addstr(len(result.splitlines()) + 2, 0, "Press any key to continue...")
        stdscr.refresh()
        stdscr.getch()  # Wait for key press
        stdscr.clear()

if __name__ == "__main__":
    curses.wrapper(main)
