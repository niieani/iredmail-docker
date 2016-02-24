#!/bin/bash
capture() {
  local pipeContents
  IFS= read -r -d '' -t 1 pipeContents || true
  
  local command="$1"
  shift
  
  [[ "$3" == 'show databases' ]] && return 1
  
  for param in "$@"
  do
    command="$command '$param'"
    # echo "$param"
  done
  
  local enter=$'\n'
  
  if [[ ! -z "$pipeContents" ]]
  then
    command="${command} <<'EOF'${enter}${pipeContents}EOF"
  fi
  
  echo "$command" >> /commands
}

[[ -z "${__sourcing+x}" ]] && capture "$(basename "$0")" "$@"