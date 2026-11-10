# Highway
Highway is a shell script to navigate you folders in shell terminal easly.  

# highway -h
highway - folder shortcut manager

USAGE 
    highway <name>                     Jump to the shortcut's folder
    highway -n <name>                  Open the shortcut in a new terminal tab
    highway -v                         Show version informations
    highway -w                         Outputs the current folder's name on shortcut list
    highway -l                         List all shortcuts
    highway -l -o                      List all shortcuts alphabetically
    highway -a <name> [path]           Add a shortcut (no path = current folder)
    highway -d <name>                  Delete a shortcut
    highway -ra                        Delete ALL shortcuts (asks for confirmation)
    highway -ep <name> <newpath>       Change the path of a shortcut
    highway -en <newname> <path>       Rename the shortcut that points to <path>
    highway -h                         Show this help
    highway -nf                        Jump to the next sibling folder
    highway -pf                        Jump to the previous sibling folder
    highway -n -nf                     Open next sibling folder in a new terminal tab
    highway -nf <positive integer>     Jump by given number folders forward

SWITCHES AND ALIASES
    -l   -list                         List shortcuts
    -v   -version                       Show version number
    -w   -whereAmI                      Print current folder's given name
    -o   -order  -sort                  Order listed shortcuts
    -n   -new_tab                      Open in a new Windows Terminal tab
    -a   -add, -append                 Add a shortcut
    -d   -r, -delete, -remove          Delete a shortcut
    -ra  -clear                        Clear the whole list
    -ep  -edit_path                    Edit the path of a shortcut
    -en  -edit_name                    Edit the name of a shortcut
    -h   -help                         Show this help
    -nf  -next_folder                  Go to next sibling folder
    -pf  -previous_folder              Go to previous sibling folder

NAME RULES
    Names cannot be empty, cannot contain spaces, '=' or '#',
    and must be unique (case-insensitive).

EXAMPLES
    highway -a work D:\Projects        Save D:\Projects as "work"
    highway work                       Go to D:\Projects
    highway -n work                    Open D:\Projects in a new tab
    highway -ep work D:\Projects\New   Point "work" to a different folder
    highway -en job D:\Projects\New    Rename that shortcut to "job"
    highway -d job                     Remove "job"

NOTES
    Paths are saved as full paths. Shortcuts are stored in shortcuts.txt
    next to the script; lines starting with # are comments.
