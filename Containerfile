ARG DEBIAN_VERSION=13.3
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
# Install OpenJDK 21 LTS (latest stable available in Debian 13).
# DL3008 suppressed — OpenJDK apt package versioning does not align
# with upstream release strings; suppression is the standard practice here.
# RUN apt-get update \
#  && apt-get install -y --no-install-recommends openjdk-21-jre-headless \
#  && apt-get clean \
# && rm -rf /var/lib/apt/lists/*
# WORKDIR /opt
# https://openjdk.org/projects/jdk/27/
# https://download.java.net/java/GA/jdk27/55ce5470a6294008af0057ff4626d0e5/35/GPL/openjdk-27_linux-aarch64_bin.tar.gz 
# https://download.java.net/java/GA/jdk27/55ce5470a6294008af0057ff4626d0e5/35/GPL/openjdk-27_linux-x64_bin.tar.gz
# ADD https://download.java.net/java/early_access/jdk25/7/GPL/openjdk-25-ea+7_linux-aarch64_bin.tar.gz jdk-25.tgz
# RUN /usr/bin/tar zxf jdk-25.tgz \
#  && /usr/bin/mv jdk-25 jdk \
#  && /usr/bin/rm jdk-25.tgz \
#  && /usr/bin/ln -fsv /opt/jdk/bin/java /usr/bin/java


WORKDIR /opt
ARG TARGETARCH
RUN case "${TARGETARCH}" in \
      amd64) JAVA_ARCH="x64" ;; \
      arm64) JAVA_ARCH="aarch64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
 && curl -fsSL \
      "https://download.java.net/java/GA/jdk27/55ce5470a6294008af0057ff4626d0e5/35/GPL/openjdk-27_linux-${JAVA_ARCH}_bin.tar.gz" \
      -o jdk.tgz \
 && tar -xzf jdk.tgz \
 && mv jdk-27 jdk \
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
