FROM alpine:edge
LABEL maintainer="Danny Lin <danny@kdrag0n.dev>"

RUN apk update
RUN apk add --no-cache openssh openssh-server bash htop coreutils findutils util-linux curl ca-certificates glances

RUN mkdir -p /root/.ssh
ADD known_hosts /root/.ssh/

RUN passwd -u root

ADD start-server.sh /
RUN chmod +x /start-server.sh

EXPOSE 22
ENTRYPOINT ["/start-server.sh"]
