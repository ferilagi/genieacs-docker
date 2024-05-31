# GenieACS v1.2 Dockerfile #
############################

FROM node:bookworm-slim
LABEL maintainer="acsdesk@protonmail.com"

USER root

RUN apt-get update && apt-get install -y sudo supervisor iputils-ping git
RUN mkdir -p /var/log/supervisor

#RUN npm install -g --unsafe-perm genieacs@1.2.11
WORKDIR /opt
RUN git clone https://github.com/genieacs/genieacs.git
WORKDIR /opt/genieacs
RUN npm install 
RUN npm i -D tslib
RUN npm run build

RUN useradd --system --no-create-home --user-group genieacs
#RUN mkdir /opt/genieacs
RUN mkdir /opt/genieacs/ext
RUN chown genieacs:genieacs /opt/genieacs/ext

RUN mkdir /var/log/genieacs
RUN chown genieacs:genieacs /var/log/genieacs

ADD genieacs.logrotate /etc/logrotate.d/genieacs

WORKDIR /opt
RUN git clone https://github.com/ferilagi/genieacs-services
RUN cp genieacs-services/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN cp genieacs-services/run_with_env.sh /usr/bin/run_with_env.sh
RUN chmod +x /usr/bin/run_with_env.sh

WORKDIR /var/log/genieacs

CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
