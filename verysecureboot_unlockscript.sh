#!/bin/sh

set -e
export TPM2TOOLS_TCTI="device:/dev/tpm0"
export OPENSSL_CONF="/conf/openssl_engine.conf"

message()
{
	if [ -x /bin/plymouth ] && plymouth --ping; then
		plymouth message --text="$*"
	else
	        echo "$@" >&2
	fi
	return 0
}


ENCRYPTED_SECRET="/conf/secret.encrypted"

pcscd --foreground > /dev/null 2>&1

message "Touch the Yubikey to boot."

SECRET_DECRYPTED=`mktemp`
openssl rsautl -engine pkcs11 -keyform engine -decrypt -inkey 3 -in $ENCRYPTED_SECRET -out $SECRET_DECRYPTED 1>&2

RESULT=$?

if [ $RESULT -eq 0 ];
then
  cat $SECRET_DECRYPTED
  rm $SECRET_DECRYPTED
  message "Success!"
  exit
fi

message "Failed to decrypt! Going into recovery mode." >&2

/lib/cryptsetup/askpass "Unlocking the disk fallback $CRYPTTAB_SOURCE ($CRYPTTAB_NAME)\nEnter passphrase: "
