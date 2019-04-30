#!/bin/sh

mkdir -p /usr/share/verysecureboot

cp verysecureboot_hook.vars /usr/share/verysecureboot/
cp engine.conf /usr/share/verysecureboot/

cp verysecureboot_unlockscript.sh /usr/share/verysecureboot/
cp verysecureboot_hook.sh /etc/initramfs-tools/hooks/

chmod +x /usr/share/verysecureboot/verysecureboot_unlockscript.sh
chmod +x /etc/initramfs-tools/hooks/verysecureboot_hook.sh
