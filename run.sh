#!/bin/bash

# Extended globs ("extglob") qualify as regular expressions; they have closure,
# union and grouping operators.
shopt -s extglob

check() {
  local -r message=$1

  # Commit Message Max Length
  if [ ${#message} -gt 100 ]; then
    fail "commit message length can not be greater than 100"
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
      fail "commit message format failed validation: \"Release vX.Y.Z-M.N\""
      exit 1
    fi
  fi

  # AngularJS Git Commit Message Conventions
  # https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y
  TYPE="feat|fix|docs|style|refactor|test|chore"
  SCOPE="\([^\)]+\)"
  SUBJECT="[^A-Z][^.]+"
  REGEX="^(${TYPE})(${SCOPE})?: (${SUBJECT})$"

  if [[ ${message} =~ ${REGEX} ]]; then
    info "commit message is valid"
    # This is valid commit message
    # exit 0
  else
    fail "commit message format failed validation: \"type(scope): message\""
    exit 1
  fi
}

commits() {
  local -r branch=$1

  git log --pretty=format:'%s' "master..${branch}"
}

main() {
  git fetch origin master &> /dev/null

  while read -r line; do
    info "${line}"
    check "${line}" || exit 1
  done <<< "$(commits "${WERCKER_GIT_BRANCH}")"

  success "commit messages validation succeeded"
}

main;
