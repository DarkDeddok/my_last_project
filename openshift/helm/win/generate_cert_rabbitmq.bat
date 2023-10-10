@echo off

call env.bat
IF not defined RABBITMQ_HOST (
    echo "RABBITMQ_HOST must be set in env.bat"
	exit 1;
)
IF not exist .rabbitmq (
	mkdir .rabbitmq
)

:: create certs here
openssl genrsa -out .rabbitmq\rabbitmq.ca.key 2048
openssl req -new -x509 -days 3650 -key .rabbitmq\rabbitmq.ca.key -out .rabbitmq\rabbitmq.ca.crt -subj "/C=CZ/ST=Test/L=Test/O=Test/OU=Test/CN=%RABBITMQ_HOST%"
echo 00 > .rabbitmq\rabbitmq.file.srl

openssl genrsa -out .rabbitmq\rabbitmq.key 2048
openssl req -new -key .rabbitmq\rabbitmq.key -out .rabbitmq\rabbitmq.csr -subj "/C=US/ST=Test/L=Test/O=Test/OU=Test/CN=%RABBITMQ_HOST%"

openssl x509 -req -days 3650 -in .rabbitmq\rabbitmq.csr -CA .rabbitmq\rabbitmq.ca.crt -CAkey .rabbitmq\rabbitmq.ca.key -CAserial .rabbitmq\rabbitmq.file.srl -out .rabbitmq\rabbitmq.crt
openssl pkcs12 -export -clcerts -in .rabbitmq\rabbitmq.crt -inkey .rabbitmq\rabbitmq.key -out .rabbitmq\rabbitmq.p12 -password pass:%RABBITMQ_JKS_PASSWORD%
openssl rsa -in .rabbitmq\rabbitmq.key -out .rabbitmq\rabbitmq.no_pem.key

copy .rabbitmq\rabbitmq.key ..\..\..\.rabbitmq\rabbitmq.key
copy .rabbitmq\rabbitmq.crt ..\..\..\.rabbitmq\rabbitmq.crt
copy .rabbitmq\rabbitmq.ca.crt ..\..\..\.rabbitmq\rabbitmq.ca.crt
copy .rabbitmq\rabbitmq.key ..\..\..\openiam-configmap\.rabbitmq\rabbitmq.key
copy .rabbitmq\rabbitmq.crt ..\..\..\openiam-configmap\.rabbitmq\rabbitmq.crt
copy .rabbitmq\rabbitmq.ca.crt ..\..\..\openiam-configmap\.rabbitmq\rabbitmq.ca.crt
