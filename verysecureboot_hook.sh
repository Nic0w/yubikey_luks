#!/bin/sh -e

if [ "$1" = "prereqs" ]; then exit 0; fi

. /usr/share/initramfs-tools/hook-functions

#OpenSSL dependencies
copy_exec /usr/lib/x86_64-linux-gnu/engines-1.1/pkcs11.so
copy_exec /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so
copy_exec /usr/lib/x86_64-linux-gnu/libpcsclite.so.1

#pcscd
copy_exec /usr/sbin/pcscd
cp -L -r --parents /usr/lib/pcsc/drivers "${DESTDIR}"
mkdir -p "${DESTDIR}/var/run/pcscd"

copy_exec /lib/x86_64-linux-gnu/libusb-1.0.so.0

#OpenSSL binary
copy_exec /usr/bin/openssl

#OpenSSL configuration
cp /usr/share/verysecureboot/engine.conf "${DESTDIR}/conf/openssl_engine.conf"

. /usr/share/verysecureboot/verysecureboot_hook.vars

cp $SECRET_SEALED "${DESTDIR}/conf/secret.encrypted"