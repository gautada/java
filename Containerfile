ARG CONTAINER_VERSION=13.3
FROM docker.io/gautada/debian:${CONTAINER_VERSION} AS container

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
# Install OpenJDK 21 LTS (latest stable available in Debian 13).
# DL3008 suppressed — OpenJDK apt package versioning does not align
# with upstream release strings; suppression is the standard practice here.
RUN apt-get update \
 && apt-get install -y --no-install-recommends openjdk-21-jre-headless \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

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
# java-running: verifies the Java runtime responds correctly to java -version.
COPY java-running.sh /etc/container/health.d/java-running
RUN chmod +x /etc/container/health.d/java-running

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
# s6 stub service: keeps the base container running.
# Downstream containers replace this with their own service definition.
COPY etc/services.d/java/run /etc/services.d/java/run
RUN chmod +x /etc/services.d/java/run

WORKDIR /home/${USER}
