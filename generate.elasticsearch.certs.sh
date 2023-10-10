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

if [ -z "$ELASTICSEARCH_HOST" ]; then
	echo "ELASTICSEARCH_HOST must be set in env.sh"
	exit 1;
fi


## create certs here
openssl genrsa -out elasticsearch.ca.key 2048
openssl req -new -x509 -days 3650 -key elasticsearch.ca.key -out elasticsearch.ca.crt -subj "/C=CZ/ST=Test/L=Test/O=Test/OU=Test/CN=${ELASTICSEARCH_HOST}"
echo -n "00" > elasticsearch.file.srl

openssl genrsa -out elasticsearch.key 2048
openssl req -new -key elasticsearch.key -out elasticsearch.csr -subj "/C=US/ST=Test/L=Test/O=Test/OU=Test/CN=${ELASTICSEARCH_HOST}"

openssl x509 -req -days 3650 -in elasticsearch.csr -CA elasticsearch.ca.crt -CAkey elasticsearch.ca.key -CAserial elasticsearch.file.srl -out elasticsearch.crt
openssl pkcs12 -export -clcerts -in elasticsearch.crt -inkey elasticsearch.key -out elasticsearch.p12 -password pass:${ELASTICSEARCH_KEY_PASSWORD}
openssl rsa -in elasticsearch.key -out elasticsearch.no_pem.key

cp elasticsearch.key .elasticsearch/elasticsearch.key
cp elasticsearch.crt .elasticsearch/elasticsearch.crt
cp elasticsearch.ca.crt .elasticsearch/elasticsearch.ca.crt
cp elasticsearch.key openiam-configmap/.elasticsearch/elasticsearch.key
cp elasticsearch.crt openiam-configmap/.elasticsearch/elasticsearch.crt
cp elasticsearch.ca.crt openiam-configmap/.elasticsearch/elasticsearch.ca.crt
