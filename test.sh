#!/bin/bash

export VERBOSE=0

for arg in $@; do
  if [[ ${arg} == "--verbose" || ${arg} == "-v" ]]; then
    export VERBOSE=1
  fi
done

function fail() {
  if [ ${VERBOSE} -eq 1 ]; then
    echo "fail: $*"
  fi
}

function success() {
  if [ ${VERBOSE} -eq 1 ]; then
    echo "success: $*"
  fi
}

function warn() {
  if [ ${VERBOSE} -eq 1 ]; then
    echo "warn: $*"
  fi
}

function info() {
  if [ ${VERBOSE} -eq 1 ]; then
    echo "info: $*"
  fi
}

export -f fail success warn info

WERCKER_GIT_BRANCH=single_valid ./run.sh
if [ $? -eq 0 ]; then
  echo "Single valid commit branch:       SUCCESS"
else
  echo "Single valid commit branch:       FAIL"
fi

WERCKER_GIT_BRANCH=multiple_valid ./run.sh
if [ $? -eq 0 ]; then
  echo "Multiple valid commits branch:    SUCCESS"
else
  echo "Multiple valid commits branch:    FAIL"
fi

WERCKER_GIT_BRANCH=single_fail ./run.sh
if [ $? -eq 1 ]; then
  echo "Single invalid commit branch:     SUCCESS"
else
  echo "Single invalid commit branch:     FAIL"
fi

WERCKER_GIT_BRANCH=multiple_fail ./run.sh
if [ $? -eq 1 ]; then
  echo "Multiple invalid commits branch:  SUCCESS"
else
  echo "Multiple invalid commits branch:  FAIL"
fi
