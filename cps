#!/bin/bash

# exit if no command is given
if [ -z "$1" ]; then
  echo -e -n "\033[0;37m" # set color to white
  echo "Error: no command given."
  exit 1
fi

keyword=Suggestion:

command=$(echo "" | gh copilot suggest -t shell "$@" 2>/dev/null | grep $keyword -A2 | grep -v $keyword)
if [ -z "$command" ]; then
    echo "Error from copilot"
    echo "Aborted."
    exit 1
fi

# echo the command
echo -e -n "\033[0;37m" # set color to white
echo $command

while true; do
  # make the user confirm the command
  read -n 1 -s -r -p $'\033[0;32mEnter\033[0;37m to execute, \033[0;33mh\033[0m to explain, any key to cancel: '

  # if the user presses h, explain the command
  if [[ $REPLY =~ ^[Hh]$ ]]; then
      echo -e -n "\033[0;32m" # set color to green
      echo $REPLY
      echo "Explaining command..."
      echo ""
      gh copilot explain "$command"
      continue
  fi

  # if the user presses any key other than Enter, exit the script
  if [[ -n $REPLY ]]; then
      echo -e -n "\033[0;31m" # set color to red
      echo "Aborted."
      exit 0
  fi

  break
done

echo -e -n "\033[0;32m" # set color to green
echo "Executing command..."
echo ""

# execute the command
echo -e "\033[0m" # reset color
eval "$command"

# Trim the command and remove newlines
trimmed_command=$(echo "$command" | sed 's/^[ \t]*//;s/[ \t]*$//' | tr -d '\n')

# Get the current timestamp and command number
timestamp=$(date +%s)
command_number=$(($(fc -l -1 | awk '{print $1}') + 1))

# Append the trimmed command to the zsh history file with the required format
echo ": $timestamp:$command_number;$trimmed_command" >> ~/.zsh_history

# Reload the history file
fc -R ~/.zsh_history
