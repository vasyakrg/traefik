#!/bin/bash

FOLDER_EXPORT=${1:-certs}

# get name - .letsEncrypt.Certificates | .[0] | .domain.main
# get key - .letsEncrypt.Certificates | .[0] | .key
# get cert - .letsEncrypt.Certificates | .[0] | .certificate

ACME=data/acme.json

LENGTH=$(cat ${ACME} | jq '.letsEncrypt.Certificates | length')

mkdir -p ${FOLDER_EXPORT}

i=1
while [ $i != ${LENGTH} ]
do

    name=$(cat ${ACME} | jq -r ".letsEncrypt.Certificates | .[${i}] | .domain.main")
    key=$(cat ${ACME} | jq -r ".letsEncrypt.Certificates | .[${i}] | .key")
    cert=$(cat ${ACME} | jq -r ".letsEncrypt.Certificates | .[${i}] | .certificate")

    echo "export ${name}"
    mkdir -p ${FOLDER_EXPORT}/${name}
    echo $key | base64 --decode > ${FOLDER_EXPORT}/${name}/privkey.pem
    echo $cert | base64 --decode > ${FOLDER_EXPORT}/${name}/cert.pem
    echo "null" > ${FOLDER_EXPORT}/${name}/fullchain.pem

    ((i++))
done
