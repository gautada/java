# java

A base container image for Java applications built on
[gautada/debian](https://github.com/gautada/debian). Provides
[OpenJDK](https://openjdk.org) downloaded directly from the official
[publication point](https://jdk.java.net/).

## Architecture

Multi-arch: `amd64` and `arm64` are both supported. The Containerfile
downloads the correct tarball for the target platform at build time.

## Version

The JDK version is controlled by build arguments in `.args`:

- `JDK_VERSION` — full version string (e.g. `27.0.1.1`)
- `JDK_HASH` — hash path component from the download URL
- `JDK_BUILD` — build number from the download URL

To update, check [jdk.java.net](https://jdk.java.net/) for the latest GA
release, extract the version, hash, and build from the download URL, and
update `.args`.

## Health checks

Health drop-ins are placed in `/etc/health.d/` and executed by
`container-test` (inherited from gautada/debian):

- `java-running` — verifies the Java runtime responds to `java -version`
- `java-latest` — verifies the installed version matches the latest GA
  release on jdk.java.net
