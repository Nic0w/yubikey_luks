#!/bin/sh

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <in:LUKS volume> <in:Key slot> <in:Encrypted secret file>"
    exit 1
fi

echo "/!\\ WARNING THIS SCRIPT IS GOING TO MESS WITH YOUR LUKS VOLUME /!\\"
echo "/!\\ IT IS ADVISED THAT YOU SETUP A BACKUP PASSPHRASE ON YOUR LUKS VOLUME BEFORE DOING THIS /!\\"
echo "CONTINUE AT YOUR OWN RISK. Ctrl-C to stop here."
read dummy

LUKS_VOLUME=$1
LUKS_KEY_SLOT=$2
SECRET_SEALED=$3

echo "Please insert Yubikey for Secret Encryption."
read dummy

#Be sure to never store the plaintext secret on disk.
SECRET=`mktemp -p /dev/shm`

#Generates a random 256 bits secret.
openssl rand -engine tpm2tss -out $SECRET 32 2> /dev/null

OPENSSL_CONF=engine.conf openssl rsautl -engine pkcs11 -keyform engine -encrypt -pubin -inkey 3 -in $SECRET -out $SECRET_SEALED

RESULT=$?

echo "Secret is now encrypted by this Yubikey."

if [ $RESULT -eq 0 ];
then

  echo "SECRET_SEALED=$(pwd)/$SECRET_SEALED" > verysecureboot_hook.vars

  echo "The secret is now going to be registered to LUKS."
  sudo cryptsetup --key-slot $LUKS_KEY_SLOT luksAddKey $LUKS_VOLUME $SECRET

fi

shred -u $SECRET
