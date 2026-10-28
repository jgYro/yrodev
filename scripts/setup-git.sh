#!/bin/sh
set -eu

project_dir=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$project_dir"

if [ -e .git ]; then
  printf 'A Git repository already exists here. Review it before changing its branch or remote.\n' >&2
  exit 1
fi

# Run from your own terminal: the agent workspace protects the root .git path.
git init -b master
git config --local user.name 'Yro LLC'
git config --local user.email 'business@yro.dev'
git config --local pull.ff only
git config --local fetch.prune true
git config --local push.default simple
git config --local core.autocrlf false
git remote add origin https://github.com/jgYro/yrodev.git
git add --all
git diff --cached --check
git commit -m 'Initialize Yro LLC website with Flutter and Firebase Hosting'
git status --short --branch
printf '\nRepository initialized on master. Remote: https://github.com/jgYro/yrodev.git\n'
printf 'Publish after GitHub authentication: git push -u origin master\n'
