#!/usr/bin/env bash

# Copyright (c) 2016 Benito Lopez under the MIT license

# INSTALL:
#     Put something like this in your .bashrc:
#         . /path/to/p.sh
#     And ensure the script is executable
#         chmod +x /path/to/p.sh
#
#     Optionally:
#         set $_P_CMD in .bashrc to change the command
#             - default 'p'
#         set $_P_DIR in .bashrc to change the projects dir
#             - default '~/.projects'
#         set $_P_OPEN_FUNC in .bashrc to change the function
#         used to open the project with your default editor
#             - default '$EDITOR .'

# Print error message and return error code
_p_print_error() {
    if [ "$2" ]; then
        echo "$2"
    fi
    if [ "$1" ]; then
        return "$1"
    else
        return 1
    fi
}

 # Print help screen
_p_print_help() {
    echo "Usage: p <option>"
    echo ""
    echo "Options:"
    echo "  <project name>           Run project(s) configuration script."
    echo "  add <project name>       Add project."
    echo "  list                     List all projects."
    echo "  delete <project name>    Delete project(s)."
    echo "  o <project name>         Open project(s) with the default editor."
    echo "  g <project name>         Go to the project(s) directory."
    echo "  edit <project name>      Edit project(s)."
    echo "  rename <old> <new>       Rename project."
    echo "  -h --help                Display this information."
    echo "  -v --version             Display version info."
    echo ""
}

# Check if project has a valid name (not reserved)
_p_check_project_name() {
    case "$1" in
        add|list|delete|edit|rename|o|-h|--help|-v|--version)
            echo "$1: Illegal name"
            return 1
    esac
}

# Check if we have the editor environment variable
_p_check_editor() {
    if [ -z "$EDITOR" ]; then
        echo "The \$EDITOR environment variable is not set."
        echo "You need to manually edit the configuration file in $p_dir."
        return 1
    fi
}

# Open the configuration file with the default editor
_p_edit_config_file() {
    $EDITOR "$p_dir/$1.sh"
}

# Open the project with the default editor
_p_open_with_editor() {
    p_path=$(sed -n "/^PROJECT_PATH=\(.*\)$/s//\1/p" $p_dir/$1.sh)

    if [ -d "$p_path" ]; then
        cd $p_path
        # Open the folder - You can override this function with $_P_OPEN_FUNC
        ${_P_OPEN_FUNC:-$EDITOR .}
    else
        _p_print_error 1 "Directory does not exist"
        return 1
    fi
}

# Go to the project directory
_p_go_to_project() {
    p_path=$(sed -n "/^PROJECT_PATH=\(.*\)$/s//\1/p" $p_dir/$1.sh)

    if [ -d "$p_path" ]; then
        # Go to the project directory
        cd $p_path
    else
        _p_print_error 1 "Directory does not exist"
        return 1
    fi
}

_p() {
    VERSION=3.0.0

    # Set projects dir (can be changed with the environment variable $_P_DIR)
    p_dir="${_P_DIR:-$HOME/.projects}"

    # Create .projects dir
    if [ ! -d "$p_dir" ]; then
        mkdir "$p_dir"
    fi

    # Initialize empty PROJECTS array
    PROJECTS=()

    # Get the list of the installed projects
    projects_files=($(find $p_dir -iname "*.sh"))

    for project in "${projects_files[@]}"; do
        name="${project##*/}"
        name="${name%.*}"
        PROJECTS+=($name)
    done

    case "$1" in
        add)
            # Add project
            if [ "$2" ]; then
                for argument in "${@:2}"; do
                    if [ -f "$p_dir/$argument.sh" ]; then
                        _p_print_error 1 "Project $argument already exists"
                        return 1
                    else
                        _p_check_project_name "$argument" || return
                        printf "#!/usr/bin/env bash\n\n# This script runs when you call the project with \"p %s\"\n\n# DO NOT DELETE THIS LINE\nPROJECT_PATH=$PWD\n\n" "$argument" > "$p_dir/$argument.sh"
                        echo "Added project $argument"
                    fi
                done
            else
                _p_print_error 1 "No project name given"
                return 1
            fi
            ;;
        list)
            # List projects
            if [ ${#PROJECTS[@]} -eq 0 ]; then
                _p_print_error 1 "There are no projects"
                return 1
            else
                for project in "${PROJECTS[@]}"; do
                    echo $project
                done
            fi
            ;;  
        delete)
            # Remove project
            if [ "$2" ]; then
                for argument in "${@:2}"; do
                    if [ -f "$p_dir/$argument.sh" ]; then
                        rm "$p_dir/$argument.sh"
                        echo "Project $argument deleted"
                    else
                        _p_print_error 1 "Project $argument does not exist"
                        return 1
                    fi
                done
            else
                _p_print_error 1 "No project name given"
                return 1
            fi
            ;;
        edit)
            # Edit project
            if [ "$2" ]; then
                for argument in "${@:2}"; do
                    if [ -f "$p_dir/$argument.sh" ]; then
                        _p_check_editor || return
                        _p_edit_config_file $argument
                    else
                        _p_print_error 1 "Project $argument does not exist"
                        return 1
                    fi
                done
            else
                _p_print_error 1 "No project name given"
                return 1
            fi
            ;;
        rename)
            # Rename project
            if [ "$2" ]; then
                if [ ! -f "$p_dir/$2.sh" ]; then
                    _p_print_error 1 "Project $2 does not exist"
                    return 1
                else
                    if [ "$3" ]; then
                        if [ -f "$p_dir/$3.sh" ]; then
                            _p_print_error 1 "Project $3 already exists"
                            return 1
                        else
                            mv "$p_dir/$2.sh" "$p_dir/$3.sh"
                            echo "Project renamed to $3"
                        fi
                    else
                        _p_print_error 1 "No new name given"
                        return 1
                    fi
                fi
            else
                return_error 1 "No name given"
                return 1
            fi
            ;;
        o)
            # Open the project with the default editor
            if [ "$2" ]; then
                for argument in "${@:2}"; do
                    if [ -f "$p_dir/$argument.sh" ]; then
                        _p_check_editor || return
                        _p_open_with_editor $argument
                    else
                        _p_print_error 1 "Project $argument does not exist"
                        return 1
                    fi
                done
            else
                _p_print_error 1 "No project name given"
                return 1
            fi
            ;;
		g)
            # Go to the project directory
            if [ "$2" ]; then
				if [ -f "$p_dir/$2.sh" ]; then
					_p_go_to_project $2
				else
					_p_print_error 1 "Project $2 does not exist"
					return 1
				fi
            else
                _p_print_error 1 "No project name given"
                return 1
            fi
            ;;
        -h|--help)
            # Show help screen
            _p_print_help
            ;;
        -v|--version)
            # Show version
            echo "P $VERSION."
            ;;
        *)
            # Empty command
            if [ -z "$1" ]; then
                _p_print_help
            # Run the project configuration file
            else
                for argument in "${@:1}"; do
                    if [ -f "$p_dir/$argument.sh" ]; then
                        . $p_dir/$argument.sh
                    else
                        _p_print_error 1 "Project $argument does not exist"
                    fi
                done
            fi
            ;;
    esac
}

alias ${_P_CMD:-p}='_p 2>&1'
