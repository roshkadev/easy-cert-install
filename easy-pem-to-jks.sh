#/bin/bash

# check parameters

PEM_KEY=$1
PEM_CERT=$2
JKS_OUT=$3
ALIAS=$4

MY_SCRIPT=$(basename "$0")

if [[ -z "$PEM_KEY" || -z "$PEM_CERT" || -z "$JKS_OUT" || -z "$ALIAS" ]]; then
    echo "Usage: $MY_SCRIPT PEM_KEY_FILE.key PEM_CERTFICATE_FILE.crt JKS_OUT_FILENAME.jks ALIAS\nWhere parameter are mostly self explanatory. I guess... ALIAS is the name to use to store values in JKS"
    exit -1
fi

# check for openssl

if ! [ -x "$(command -v openssl)" ]; then
  echo 'Error: openssl is not installed.' >&2
  exit -1
fi

if ! [[ -f $PEM_KEY ]]
then
    echo "$PEM_KEY does not exists. Supplied key pem file must exists and be read accessible."
    exit -1
fi

if ! [[ -f $PEM_CERT ]]
then
    echo "$PEM_CERT does not exists. Supplied certificate pem file must exists and be read accessible."
    exit -1
fi

# get java
JAVA_HOME=$(java -XshowSettings:properties -version 2>&1 > /dev/null | grep 'java.home' | awk '{split($0,array," = ")} END {print array[2]}')
echo "Using JAVA_HOME=$JAVA_HOME"

KEYTOOL=$JAVA_HOME/bin/keytool
echo "Using keytool: $KEYTOOL"

CACERTS=()

JAVA_HOME_CACERTS=$JAVA_HOME/lib/security/cacerts
if [[ -f $JAVA_HOME_CACERTS ]]; then
    CACERTS+=$JAVA_HOME_CACERTS
fi

echo "Converting PEM files to PKCS12"

FTMP=$(mktemp).p12

openssl pkcs12 -export -in $PEM_CERT -inkey $PEM_KEY -out $FTMP -name $ALIAS

echo "Importing certificate file $PEM_CERT"

$KEYTOOL -importkeystore -srckeystore $FTMP -srcstoretype pkcs12 -destkeystore $JKS_OUT

echo "Removing temp file $FTMP"
rm -v $FTMP







