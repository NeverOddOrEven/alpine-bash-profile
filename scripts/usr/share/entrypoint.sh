#!/bin/bash

echo
echo "Welcome $(whoami), from '/usr/share/entrypoint.sh'"
echo
# See: https://unix.stackexchange.com/q/26676
[[ $- == *i* ]] \
    && echo 'This is an interactive shell' \
    || echo 'This is not an interactive shell'

# See: https://unix.stackexchange.com/q/26676
shopt -q login_shell \
    && echo 'This is a login shell' \
    || echo 'This is not a login shell'

echo 

# if the first parameter is a flag, set the executable to bash
# otherwise, use the supplied command 
cmd="$@" 
if [[ "$1" =~ ^- ]]; then
    cmd="bash"
fi

while [[ $# -gt 0 ]]; do
    arg="$1"

    case $arg in 
       --some-var|-s)
            # This just assumes the input is good. 
            # In a real script, you will want to check that for yourself.
            cat >> /usr/share/entrypoint/known_args - <<< "export SOME_VAR='$2'"
            shift
            shift
            ;;
        bash)
            # This is the default command from the Dockerfile if no other 
            # commands or flags are specified. We must handle it, or else 
            # it will be considered an 'unknown_arg' and will print out a 
            # harmless but worrisome diagnostic saying as much.
            shift
            ;;
        *)  
            # Storing each per line enables easier post-processing,
            # as it obviates the need to handle spaces explicitly
            cat >> /usr/share/entrypoint/unknown_args - <<< "$1"
            shift
            ;;
    esac
done 

if [[ -f "/usr/share/entrypoint/unknown_args" ]]; then
    echo "These unknown options were not processed"
    cat /usr/share/entrypoint/unknown_args
    echo
fi

if [[ -f "/usr/share/entrypoint/known_args" ]]; then
    echo "Setting known flags"
    cat /usr/share/entrypoint/known_args
    . /usr/share/entrypoint/known_args
    echo
fi

# Run the supplied command w/supplied flags and values 
cd $HOME && exec "$cmd"
