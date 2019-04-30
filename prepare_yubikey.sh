#!/bin/sh

PUBLIC_KEY=`mktemp`
CERTIFICATE=`mktemp`
DEFAULT_SLOT="9d"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <in:Yubikey name>"
    exit 1
fi

YUBIKEY_NAME=$1

echo "Generating private key..."
yubico-piv-tool -s $DEFAULT_SLOT -a generate -A RSA2048 -o $PUBLIC_KEY --touch-policy always

echo "Generating self-signed certificate. Enter your PIN then touch the Yubikey!"
yubico-piv-tool -s $DEFAULT_SLOT -a verify-pin -a selfsign-certificate --valid-days=3650 -S "/CN=$YUBIKEY_NAME/OU=Certificate Authority/O=LlamaNetwork/"  -i $PUBLIC_KEY -o $CERTIFICATE

yubico-piv-tool -a import-certificate -s $DEFAULT_SLOT -i $CERTIFICATE
