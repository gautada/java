ARG DEBIAN_VERSION=13.7
FROM docker.io/gautada/debian:${DEBIAN_VERSION} AS container

ARG IMAGE_NAME=java

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="A base container for Java (OpenJDK)."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/${IMAGE_NAME}"
LABEL org.opencontainers.image.source="https://github.com/gautada/${IMAGE_NAME}"
LABEL org.opencontainers.image.license="Upstream"

# ╭――――――――――――――――――――╮
# │ PACKAGES           │
# ╰――――――――――――――――――――╯
# Install OpenJDK from the official publication point (jdk.java.net).
# Multi-arch: downloads the correct tarball for amd64 or arm64.
# https://jdk.java.net/27/
WORKDIR /opt
ARG TARGETARCH
ARG JDK_VERSION=27.0.1.1
ARG JDK_HASH=c3a705caf5044be8aa0b09e62be69b20
ARG JDK_BUILD=4
RUN case "${TARGETARCH}" in \
      amd64) JAVA_ARCH="x64" ;; \
      arm64) JAVA_ARCH="aarch64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
 && curl -fsSL \
      "https://download.java.net/java/GA/jdk${JDK_VERSION}/${JDK_HASH}/${JDK_BUILD}/GPL/openjdk-${JDK_VERSION}_linux-${JAVA_ARCH}_bin.tar.gz" \
      -o jdk.tgz \
 && tar -xzf jdk.tgz \
 && mv jdk-* jdk \
 && rm jdk.tgz \
 && ln -fsv /opt/jdk/bin/java /usr/bin/java

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
# Rename the base user to this container user.
# Follows the same pattern as other gautada containers.
ARG OLDUSER=debian
ARG USER=duke
RUN /usr/sbin/usermod -l $USER $OLDUSER \
 && /usr/sbin/usermod -d /home/$USER -m $USER \
 && /usr/sbin/groupmod -n $USER $OLDUSER \
 && PASSWORD="$(openssl rand -base64 32 | tr -dc 'A-Za-z0-9' | head -c 24)" \
 && printf '%s:%s\n' "$USER" "$PASSWORD" | /usr/sbin/chpasswd

# ╭――――――――――――――――――――╮
# │ VERSION            │
# ╰――――――――――――――――――――╯
# Provides /usr/bin/container-version — returns the installed OpenJDK version.
COPY usr/bin/container-version /usr/bin/container-version
RUN chmod +x /usr/bin/container-version

# ╭――――――――――――――――――――╮
# │ HEALTH             │
# ╰――――――――――――――――――――╯
# Health drop-ins into /etc/health.d/ (inherited from gautada/debian).
# java-running: verifies the Java runtime responds correctly.
# java-latest: verifies the installed JDK matches the latest GA from jdk.java.net.
COPY java-running.sh /etc/health.d/java-running
COPY java-latest.sh /etc/health.d/java-latest
RUN chmod +x /etc/health.d/java-running /etc/health.d/java-latest

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
# s6 stub service: keeps the base container running.
# Downstream containers replace this with their own service definition.
COPY etc/services.d/java/run /etc/services.d/java/run
RUN chmod +x /etc/services.d/java/run

WORKDIR /home/${USER}
