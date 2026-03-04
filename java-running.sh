#!/bin/sh
#
# Health check: verifies the Java runtime is functional.
# Runs `java -version` and checks the exit code.
# Returns 0 if Java is operational, non-zero otherwise.

if java -version > /dev/null 2>&1; then
  echo "java-running: Java runtime is functional ($(/usr/bin/container-version))"
  exit 0
fi

echo "java-running: Java runtime check failed"
exit 1
