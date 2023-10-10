#!/usr/bin/env bash

set -e

. env.sh

if [ -f /opt/openiam/webapps/env.sh ]
then
  . /opt/openiam/webapps/env.sh
fi

if [ ! -z "$OPENIAM_LOG_LEVEL" ] && [ "$OPENIAM_LOG_LEVEL" == "debug" ] || [ "$OPENIAM_LOG_LEVEL" == "trace" ]
then
  set -x
fi

if [ -z "$RABBITMQ_HOST" ]; then
	echo "RABBITMQ_HOST must be set in env.sh"
	exit 1;
fi


## create certs here
openssl genrsa -out rabbitmq.ca.key 2048
openssl req -new -x509 -days 3650 -key rabbitmq.ca.key -out rabbitmq.ca.crt -subj "/C=CZ/ST=Test/L=Test/O=Test/OU=Test/CN=${RABBITMQ_HOST}"
echo -n "00" > rabbitmq.file.srl

openssl genrsa -out rabbitmq.key 2048
openssl req -new -key rabbitmq.key -out rabbitmq.csr -subj "/C=US/ST=Test/L=Test/O=Test/OU=Test/CN=${RABBITMQ_HOST}"

openssl x509 -req -days 3650 -in rabbitmq.csr -CA rabbitmq.ca.crt -CAkey rabbitmq.ca.key -CAserial rabbitmq.file.srl -out rabbitmq.crt
openssl pkcs12 -export -clcerts -in rabbitmq.crt -inkey rabbitmq.key -out rabbitmq.p12 -password pass:${RABBITMQ_JKS_PASSWORD}
openssl rsa -in rabbitmq.key -out rabbitmq.no_pem.key

cp rabbitmq.key .rabbitmq/rabbitmq.key
cp rabbitmq.crt .rabbitmq/rabbitmq.crt
cp rabbitmq.ca.crt .rabbitmq/rabbitmq.ca.crt
cp rabbitmq.key openiam-configmap/.rabbitmq/rabbitmq.key
cp rabbitmq.crt openiam-configmap/.rabbitmq/rabbitmq.crt
cp rabbitmq.ca.crt openiam-configmap/.rabbitmq/rabbitmq.ca.crt