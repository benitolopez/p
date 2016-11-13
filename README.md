# P

**P** is a minimal project automator for Bash. It was inspired by [prm](https://github.com/eivind88/prm), an awesome project of Eivind Arvesen. While I'm still thinking that *prm* is very good, I was looking for a project manager with a different logic and more simple. During the day, I switch between projects constantly, losing a lot of time. Sometimes I need to start some common tasks (launch Vim, start Gulp and so on), but often I only need to open the project with my editor.

That's why I have created **P**.

## How it works

When you run **P**, you run the script associated to your project. You can open a new shell window, start a task runner or run a command. It's up to you. **P** creates this script with only one variable, `PROJECT_PATH`, the path of your project.

Example:

```bash
# cd to your project directory
cd $PROJECT_PATH

# run Gulp
gulp
```

## Installation

Clone this repository:

```bash
git clone https://github.com/benitolopez/p.git
```

Then add something like this in your `.bashrc`:

```bash
. /path/to/p.sh
```

And ensure the script is executable

```bash
chmod +x /path/to/p.sh
```

## Usage

```bash
Usage: p <option>

    Options:
	<project name>           Run project(s) configuration script.
    add <project name>       Add project.
    list                     List all projects.
    delete <project name>    Delete project(s).
    o <project name>         Open project(s) with the default editor.
	g <project name>         Open new shell window in the project(s) directory.
    edit <project name>      Edit project(s).
	rename <old> <new>       Rename project.
    -h --help                Display this information.
    -v --version             Display version info.
```

So, to add a project just run `p add <project name>` from the root of your project. This creates a `<project name>.sh` file in `~/.projects/`. Then you can run that script with `p <project name>`.

You can run multiple projects at once with:

```bash
p <project1 name> <project2 name> <project3 name>
```

But sometimes you only need a quick way to open a project with your default editor. In this case, just run (multiple projects allowed):

```bash
p o <project name>
```

And to open a new shell window in the project directory run (multiple projects allowed):

```bash
p g <project name>
```

## Options

You can modify some defaults exporting these environment variables:

```
_P_CMD           # the P command, default 'p'
_P_DIR           # projects directory where the scripts are saved
                   default '~/.projects'
_P_OPEN_FUNC     # function used to open the project with 
                   your default editor, default '$EDITOR .'
_P_GO_FUNC       # function used to open a new shell window in the project directory
                   default 'gnome-terminal --working-directory=/path/to/project/'
```

## License

[MIT](http://opensource.org/licenses/MIT)
Copyright (c) 2016 [Benito Lopez](http://lopezb.com)
