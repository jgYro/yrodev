#!/bin/sh
set -eu

project_dir=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
cd "$project_dir"

read -r expected_flutter < .flutter-version
actual_flutter=$(flutter --version --machine)
case "$actual_flutter" in
  *\"frameworkVersion\":\ \""$expected_flutter"\"*) ;;
  *)
    printf 'This project requires Flutter %s. Select that SDK before running checks.\n' "$expected_flutter" >&2
    exit 1
    ;;
esac

# Dependencies must already match pubspec.lock. These checks do not resolve them.
flutter analyze --no-pub
flutter test --no-pub
flutter build web --no-pub --no-web-resources-cdn
