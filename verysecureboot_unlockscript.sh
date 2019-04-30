#!/bin/sh

set -e
export TPM2TOOLS_TCTI="device:/dev/tpm0"
export OPENSSL_CONF="/conf/openssl_engine.conf"

ENCRYPTED_SECRET="/conf/secret.encrypted"

pcscd --foreground > /dev/null 2>&1 &

SECRET_DECRYPTED=`mktemp`
openssl rsautl -engine pkcs11 -keyform engine -decrypt -inkey 3 -in $ENCRYPTED_SECRET -out $SECRET_DECRYPTED 1>&2

RESULT=$?

if [ $RESULT -eq 0 ];
then
  cat $SECRET_DECRYPTED
  echo "Success!" >&2
  exit
fi

echo "Failed to decrypt! Going into recovery mode." >&2

/lib/cryptsetup/askpass "Unlocking the disk fallback $CRYPTTAB_SOURCE ($CRYPTTAB_NAME)\nEnter passphrase: "
