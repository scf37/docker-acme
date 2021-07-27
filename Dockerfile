FROM scf37/base:latest

RUN mkdir -p /root/.acme.sh && \
  cd /root/.acme.sh && \
  wget https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh && \
  chmod 777 acme.sh && \
  /root/.acme.sh/acme.sh --uninstallcronjob  && \
  apt-get -y update && apt-get -y install docker.io && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh

ENTRYPOINT ["/run.sh"]