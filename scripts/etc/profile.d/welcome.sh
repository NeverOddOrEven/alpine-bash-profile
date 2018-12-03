#!/bin/bash

# For more information regarding bash shells, see:
# https://www.gnu.org/software/bash/manual/bash.html#Bash-Startup-Files

echo
echo "Welcome $(whoami), from '/etc/profile.d/welcome.sh'"
echo "Sourced by: $0."
echo

# colorized pretty print "username pwd $ "
export PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u \[\033[01;34m\]\w \$\[\033[00m\] '

# See: https://unix.stackexchange.com/q/26676
[[ $- == *i* ]] \
    && echo 'This is an interactive shell' \
    || echo 'This is not an interactive shell'

# See: https://unix.stackexchange.com/q/26676
shopt -q login_shell \
    && echo 'This is a login shell' \
    || echo 'This is not a login shell'

echo 

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
