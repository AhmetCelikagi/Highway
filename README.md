# Highway 
## What is it?
Highway is a shell script to help users navigate in shell environment easier. Whether it is PowerShell or Bash with this script one can:
- Open paths that are saved in shortcut list
- Add and delete paths in shortcut list
- Prune invalid paths in shortcut list
- Edit shortcuts in shell environment
- Print shortcut list
- Navigate to sibling folders
  
## Dev Notes
Usage of this script is simple to use and one can write "highway -h" in shell to learn more. 
I created this scripts to both learn and navigate in shell easier rather then writing cd command many times. 
I use this script daily and I would like to share with anyone who has the same problem.
I also like any thoughts on improvements and bug reports.
Bash part of this behind, and lacks some features PowerShell part has.
I am still improving both to make them more polished.

## Installation
Because Highway changes the working directory of your active terminal session, it must be sourced into your shell profile rather than executed as a standalone script.
First clone the repository:
`git clone <your-repo-url> ~/.highway`
Do following steps and then verify with:
`highway -h`

### For PowerShell
1- Allow local scripts to run (Windows only):
`Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

2- Create a profile if one does not exist:
`if (!(Test-Path -Path $PROFILE)) { New-Item -ItemType File -Path $PROFILE -Force }`

3- Source the script in your profile and reload:
`Add-Content -Path $PROFILE -Value "`n. `"$HOME\.highway\highway.ps1""`
`. $PROFILE`

### For Bash: 
Add the script to your ~/.bashrc (or ~/.bash_profile on macOS) and reload:
`echo 'source ~/.highway/highway.sh' >> ~/.bashrc`
`source ~/.bashrc`



## Usage:
### PowerShell:
	`highway <name>                     Jump to the shortcut's folder`

    `highway -n <name>                  Open the shortcut in a new terminal tab`

    `highway -v                         Show version informations`

    `highway -w                         Outputs the current folder's name on shortcutlist`

    `highway -l                         List all shortcuts`

    `highway -l -o                      List all shortcuts alphabetically`

    `highway -a <name> [path]           Add a shortcut (no path = current folder)`

    `highway -d <name>                  Delete a shortcut`

    `highway -p                         Find and remove invalid shortcuts`

    `highway -ra                        Delete ALL shortcuts (asks for confirmation)`

    `highway -ep <name> <newpath>       Change the path of a shortcut`

    `highway -en <name> <newname>       Rename an existing shortcut`

    `highway -h                         Show this help`

    `highway -nf                        Jump to the next sibling folder`

    `highway -pf                        Jump to the previous sibling folder`

    `highway -n -nf                     Open next sibling folder in a new terminal tab`

    `highway -nf <positive integer>     Jump by given number folders forward`

### Bash:
`highway <name>                     Jump to the shortcut's folder`

## Known Bugs
- [ ] Parameters do not work together. Parameter Sets required.
- [ ] Renaming "work" to "WORK" is not allowed. Since it gives name already exist error.

## Roadmap
- [ ] Bash will have features that PowerShell has
- [ ] Tab Completion
- [ ] Typo Checker
- [ ] Subpaths
- [ ] Tags
- [ ] Polishing


