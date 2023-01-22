#!/bin/bash

function help {
    echo 
    echo "letsencrypt integration"
    echo "Parameters, must be passed in as env variables:"
    echo " DOMAINS space-separated domain names for this cert. example: 'host.me www.host.me'"
    echo " WEBROOT root directory of web server. example: '/nginx'"
    echo " KEYPATH path for ssl cert key. example: '/nginx/host.pem'"
    echo " CERTPATH path for ssl chained certs. example: '/nginx/host-cert.pem'"
    echo " SERVER_CONTAINER web application server container name in local docker installation. example: 'cnginx'"
    exit 1
}

if [ -z "$DOMAINS" ]; then
    echo "DOMAINS is not defined"
    help
fi

if [ -z "$WEBROOT" ]; then
    echo "WEBROOT is not defined"
    help
fi

if [ -z "$KEYPATH" ]; then
    echo "KEYPATH is not defined"
    help
fi

if [ -z "$CERTPATH" ]; then
    echo "CERTPATH is not defined"
    help
fi

if [ -z "$SERVER_CONTAINER" ]; then
    echo "SERVER_CONTAINER is not defined"
    help
fi


#trim domains string
DOMAINS=$(echo -e "${DOMAINS}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

array=($DOMAINS)
#first specified domain is primary one
PRIMARY_DOMAIN=${array[0]}

ACME_ISSUE_DOMAINS=$(echo -e " ${DOMAINS}" | sed -re 's/[[:space:]]+/ -d /g')

echo [$(date)]" Starting acme client" >> /data/log.log
echo "  DOMAINS=$DOMAINS" >> /data/log.log
echo "  WEBROOT=$WEBROOT" >> /data/log.log
echo "  KEYPATH=$KEYPATH" >> /data/log.log
echo "  CERTPATH=$CERTPATH" >> /data/log.log
echo "  SERVER_CONTAINER=$SERVER_CONTAINER" >> data/log.log

while true ; do
    sum=$([ -e "$KEYPATH" ] && cat $KEYPATH | sha1sum)$([ -e "$CERTPATH" ] && cat $CERTPATH | sha1sum)
    /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    /root/.acme.sh/acme.sh --register-account -m scf370@gmail.com
    /root/.acme.sh/acme.sh --issue $ACME_ISSUE_DOMAINS  -w $WEBROOT 2>&1 >> /data/log.log
    /root/.acme.sh/acme.sh --installcert -d $PRIMARY_DOMAIN --keypath $KEYPATH --fullchainpath $CERTPATH 2>&1 >> /data/log.log

    sum2=$([ -e "$KEYPATH" ] && cat $KEYPATH | sha1sum)$([ -e "$CERTPATH" ] && cat $CERTPATH | sha1sum)

    if [ "$sum" != "$sum2" ]; then
	echo [$(date)]" SSL cert changed, restarting web server" >> /data/log.log
	docker restart $SERVER_CONTAINER >> /data/log.log
    fi
    echo [$(date)] Sleeping for 12 hours... >> /data/log.log
    sleep 12h

done

