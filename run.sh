#!/bin/bash

# Extended globs ("extglob") qualify as regular expressions; they have closure,
# union and grouping operators.
shopt -s extglob

check() {
  local -r message=$1

  # Commit Message Max Length
  if [ ${#message} -gt 100 ]; then
    fail "commit message \"${message}\" can not be longer than 100 chars"
    setMessage "\"${message}\" is not a valid commit"
    exit 1
  fi

  # Version Release Commit Message
  if [[ ${message} =~ ^Release ]]; then
    regex="^Release v[[:digit:]]+(.[[:digit:]]+){2}(-[a-z]+.[[:digit:]]+)?$"
    if [[ ${message} =~ ${regex} ]]; then
      info "commit message is valid"
      # This is a valid release commit message
      # exit 0
    else
      fail "commit message \"${message}\" failed validation: \"Release vX.Y.Z-M.N\""
      setMessage "\"${message}\" is not a valid commit"
      exit 1
    fi
  fi

  # AngularJS Git Commit Message Conventions
  # https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y
  TYPE="feat|fix|docs|style|refactor|test|chore|revert"
  SCOPE="\([^\)]+\)"
  SUBJECT="[^A-Z][^.]+"
  REGEX="^(${TYPE})(${SCOPE})?: (${SUBJECT})$"

  if [[ ${message} =~ ${REGEX} ]]; then
    info "commit message is valid"
    # This is valid commit message
    # exit 0
  else
    fail "commit message \"${message}\" failed validation: \"type(scope): message\""
    setMessage "\"${message}\" is not a valid commit"
    exit 1
  fi
}

commits() {
  local -r branch=$1

  git log --pretty=format:'%s' "master..${branch}"
}

main() {
  if [ -z "${GIT_HEAD}" ]; then
    export GIT_HEAD=HEAD
  fi

  while read -r line; do
    # Return if there are no commits
    if [[ "${line}" == "" ]]; then
      exit
    fi

    info "commit message \"${line}\""
    check "${line}" || exit 1
  done <<< "$(commits "${GIT_HEAD}")"

  success "commit messages are valid"
}

main;
