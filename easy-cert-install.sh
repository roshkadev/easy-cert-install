#/bin/bash

# check parameters

HOST=$1
PORT=$2
ALIAS=$3

MY_SCRIPT=$(basename "$0")

if [[ -z "$HOST" || -z "$PORT" || -z "$ALIAS" ]]; then
    echo "Usage: $MY_SCRIPT HOST PORT ALIAS\nWhere HOST and PORT are the HTTPS services you need to connect to and ALIAS is the name of the KEYSTORE ENTRY"
    exit -1
fi

# check for openssl

if ! [ -x "$(command -v openssl)" ]; then
  echo 'Error: openssl is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed.' >&2
  exit 1
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

for i in "${!CACERTS[@]}"; do
    echo "${i+1}) ${CACERTS[$i]}"
done

LAST_OPTION=${#CACERTS[@]}
let "LAST_OPTION+=1"

echo "$LAST_OPTION) Enter Your Own CACERTS/KEYSTORE file"
echo ""
echo "Where do you want to install the new certificate [1]? "

read USERIN

if [ -z "$USERIN" ]; then
    USERIN=0
else
    let "USERIN-=1"
fi

if [ $(($USERIN+0)) -eq $(($LAST_OPTION-1)) ]; then
    echo "Enter full path of keystore: "
    read CACERTS_FILE
else
    if [ -z "${CACERTS[USERIN]}" ]; then
        echo "Invalid option. Try again."
    else
        CACERTS_FILE=${CACERTS[USERIN]}
    fi
fi

if ! [[ -f $CACERTS_FILE ]]; then
    echo "Invalid cacerts/keystore file: $CACERTS_FILE"
    exit -1
fi

echo "Getting certificate from HOST: $HOST PORT: $PORT"

TMP_PEM="$(mktemp)"
TMP_DER="$(mktemp)"

echo | openssl s_client -showcerts -connect $HOST:$PORT > $TMP_PEM
openssl x509 -outform der -in $TMP_PEM -out $TMP_DER

$KEYTOOL -import -alias $ALIAS -keystore $CACERTS_FILE -file $TMP_DER


