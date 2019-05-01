#!/bin/sh

set -e
export OPENSSL_CONF="/conf/openssl_engine.conf"

ENCRYPTED_SECRET="/conf/secret.encrypted"
FALLBACK_MESSAGE="Unlocking the disk fallback $CRYPTTAB_SOURCE ($CRYPTTAB_NAME)\nEnter passphrase: "

plymouth_present()
{
	return $([ -x /bin/plymouth ] && plymouth --ping)
}

message()
{
	if plymouth_present; then
		plymouth message --text="$*" >&2 &
	else
	        echo "$@" >&2
	fi
	return 0
}

askpassword()
{
	if plymouth_present; then
		plymouth ask-for-password --prompt $FALLBACK_MESSAGE
	else
		/lib/cryptsetup/askpass $FALLBACK_MESSAGE
	fi
	return 0
}

message "Hello!"

pcscd --foreground > /dev/null 2>&1 &

ykinfo -q -H > /dev/null 2>&1

RESULT=$?

if [ $RESULT -eq 1 ];
then
	message "Yubikey not present."
	askpassword
	exit
fi

message "Touch the Yubikey to boot."

SECRET_DECRYPTED=`mktemp`
openssl rsautl -engine pkcs11 -keyform engine -decrypt -inkey 3 -in $ENCRYPTED_SECRET -out $SECRET_DECRYPTED 1>&2 &

RESULT=$?

if [ $RESULT -ne 1 ];
then
	message "Failed to decrypt! Going into recovery mode."
	askpassword
  exit
fi

cat $SECRET_DECRYPTED
rm $SECRET_DECRYPTED
message "Success!"
