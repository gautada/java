#!/bin/sh
#
# Returns the version of the installed OpenJDK runtime.
# Parses the output of `java -version` and returns the version string.
# Returns non-zero if the version cannot be determined.

VERSION=$(java -version 2>&1 | grep -oE '"[0-9]+(\.[0-9]+)*"' | tr -d '"' | head -1)

if [ -z "$VERSION" ] || [ "$VERSION" = "null" ]; then
  echo "Failed to determine Java version" >&2
  exit 1
fi

printf '%s\n' "$VERSION"
