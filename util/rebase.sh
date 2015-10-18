#!/bin/bash

while read -r branch; do
  if [ "${branch}" != "master" ]; then
    git checkout "${branch}"
    git rebase master
    git push -f
  fi
done <<< "$(git branch --list --no-color --no-column | tr -d " *")"

git checkout master
