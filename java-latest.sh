#!/bin/sh
#
# Health check: verifies the installed JDK matches the latest GA release
# published at jdk.java.net. Scrapes the download page for the current
# version string and compares it to the installed version.
# Returns 0 if versions match, non-zero otherwise.

INSTALLED=$(/usr/bin/container-version 2>/dev/null)
if [ -z "$INSTALLED" ]; then
  echo "java-latest: cannot determine installed version"
  exit 1
fi

# Extract the major version to find the right publication page
MAJOR=$(echo "$INSTALLED" | cut -d. -f1)

# Scrape the jdk.java.net page for the latest GA tarball version
LATEST=$(curl -fsSL "https://jdk.java.net/${MAJOR}/" 2>/dev/null \
  | grep -oE 'openjdk-[0-9]+(\.[0-9]+)*_linux' \
  | head -1 \
  | sed 's/^openjdk-//;s/_linux$//')

if [ -z "$LATEST" ]; then
  echo "java-latest: cannot determine latest version from jdk.java.net/${MAJOR}/"
  exit 1
fi

if [ "$INSTALLED" = "$LATEST" ]; then
  echo "java-latest: ${INSTALLED} is current"
  exit 0
fi

echo "java-latest: installed ${INSTALLED} != latest ${LATEST}"
exit 1
