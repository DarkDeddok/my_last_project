@echo off

call env.bat
IF not defined ELASTICSEARCH_HOST (
    echo "ELASTICSEARCH_HOST must be set in env.bat"
	exit 1;
)
IF not exist .elasticsearch (
	mkdir .elasticsearch
)

:: create certs here
openssl genrsa -out .elasticsearch\elasticsearch.ca.key 2048
openssl req -new -x509 -days 3650 -key .elasticsearch\elasticsearch.ca.key -out .elasticsearch\elasticsearch.ca.crt -subj "/C=CZ/ST=Test/L=Test/O=Test/OU=Test/CN=%ELASTICSEARCH_HOST%"
echo 00 > .elasticsearch\elasticsearch.file.srl

openssl genrsa -out .elasticsearch\elasticsearch.key 2048
openssl req -new -key .elasticsearch\elasticsearch.key -out .elasticsearch\elasticsearch.csr -subj "/C=US/ST=Test/L=Test/O=Test/OU=Test/CN=%ELASTICSEARCH_HOST%"

openssl x509 -req -days 3650 -in .elasticsearch\elasticsearch.csr -CA .elasticsearch\elasticsearch.ca.crt -CAkey .elasticsearch\elasticsearch.ca.key -CAserial .elasticsearch\elasticsearch.file.srl -out .elasticsearch\elasticsearch.crt
openssl pkcs12 -export -clcerts -in .elasticsearch\elasticsearch.crt -inkey .elasticsearch\elasticsearch.key -out .elasticsearch\elasticsearch.p12 -password pass:%ELASTICSEARCH_KEY_PASSWORD%
openssl rsa -in .elasticsearch\elasticsearch.key -out .elasticsearch\elasticsearch.no_pem.key

copy .elasticsearch\elasticsearch.key ..\..\..\.elasticsearch\elasticsearch.key
copy .elasticsearch\elasticsearch.crt ..\..\..\.elasticsearch\elasticsearch.crt
copy .elasticsearch\elasticsearch.ca.crt ..\..\..\.elasticsearch\elasticsearch.ca.crt
copy .elasticsearch\elasticsearch.key ..\..\..\openiam-configmap\.elasticsearch\elasticsearch.key
copy .elasticsearch\elasticsearch.crt ..\..\..\openiam-configmap\.elasticsearch\elasticsearch.crt
copy .elasticsearch\elasticsearch.ca.crt ..\..\..\openiam-configmap\.elasticsearch\elasticsearch.ca.crt
