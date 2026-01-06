ARG ALPINE_VERSION=3.22

FROM gautada/alpine:$ALPINE_VERSION as CONTAINER

# ╭――――――――――――――――――――╮
# │ VARIABLES          │
# ╰――――――――――――――――――――╯
ARG IMAGE_NAME="java"
ARG PACKAGES="openjdk25"
# ARG PACKAGE_VERSION="25.0.0"
# ARG PACKAGE_BUILD="p36"
# ARG PACKAGE_RELEASE="r0"

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="A base container for java."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/${IMAGE_NAME}"
LABEL org.opencontainers.image.source="https://github.com/gautada/${IMAGE_NAME}"
LABEL org.opencontainers.image.version="${PACKAGE_VERSION}"
LABEL org.opencontainers.image.license="Upstream"

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
ARG USER=duke # Original name of the java mascot
RUN /usr/sbin/usermod -l $USER alpine \
  && /usr/sbin/usermod -d /home/$USER -m $USER \
  && /usr/sbin/groupmod -n $USER alpine \
  && /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭――――――――――――――――――――╮
# │ BACKUP             │
# ╰――――――――――――――――――――╯
# COPY backup.sh /etc/container/backup

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
COPY entrypoint.sh /etc/container/entrypoint


# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
ARG MIRROR="mirrors.edge.kernel.org" 
# RUN /bin/sed -i 's|dl-cdn.alpinelinux.org|${MIRROR}|g' /etc/apk/repositories
# RUN cat /etc/apk/repositories
RUN echo "https://${MIRROR}/alpine/edge/testing" >>  /etc/apk/repositories \
 && /sbin/apk add --no-cache "${PACKAGES}"
 # \ "${PACKAGE_NAME}=${PACKAGE_VERSION}_${PACKAGE_BUILD}-${PACKAGE_RELEASE}"
WORKDIR /home/$USER

