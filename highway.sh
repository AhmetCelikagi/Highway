_HIGHWAY_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/shortcuts.txt"

highway() {
    local name="$1" target="" line key value

    if [[ ! -f $_HIGHWAY_FILE ]]; then
        echo "Shortcuts file not found: $_HIGHWAY_FILE" >&2
        return 1
    fi

    while IFS= read -r line || [[ -n $line ]]; do
        line=${line%$'\r'}
        [[ $line == '#'* || $line == ';'* ]] && continue
        [[ $line != *=* ]] && continue
        key=${line%%=*}
        value=${line#*=}
        if [[ ${key,,} == "${name,,}" ]]; then
            target=$value
        fi
    done < "$_HIGHWAY_FILE"

    if [[ -z $target ]]; then
        echo "No shortcut named \"$name\"" >&2
        return 1
    fi

    if [[ $target =~ ^[A-Za-z]:[\\/] ]] && command -v wslpath >/dev/null 2>&1; then
        target=$(wslpath -u "$target")
    fi

    if [[ ! -d $target ]]; then
        echo "Folder not found: $target" >&2
        return 1
    fi

    cd -- "$target"
}