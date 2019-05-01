# Yubikey + LUKS
This repository contains scripts and a initramfs hook to use a Yubikey to decrypt a secret at boot that will be used to unlock a LUKS partition.

# What does it do ?

A secret (32 random bytes from the TPM) is created. That secret is encrypted using a Yubikey thanks to OpenSSL and the PKCS#11 engine.
The cleartext version of the secret is then registered as a passphrase for a LUKS encrypted drive of the user's chosing.

A initramfs hook set the required files up so that everything that is needed to decrypt said secret is present in the initrd image at boot.

A keyscript is then used at boot to decrypt the secret if the Yubikey is present. If so, the decrypted secret is fed to cryptsetup.
Done!

# Usage

0. SETUP A BACKUP PASSPHRASE FOR YOUR LUKS DRIVE
1. Setup a Yubikey using prepare_yubikey.sh . This will create and import a certificate in slot 9d of the PIV applet. 
2. Prepare and encrypt a secret using prepare_encrypt_secret.sh . This is going to create the secret, encrypt it, set it as a LUKS passphrase for your device.
3. Run install.sh as root. This will copy the files at the right place.
4. Register /usr/share/verysecureboot/verysecureboot_unlock.sh as a keyscript in your /etc/crypttab.
5. Run update-initramfs -u as root. This will update your initramfs with the new content.
6. Reboot

If anything doesn't work as planned you'll likely be dropped in a rescue root shell from where you'll be able to unlock your encrypted drive using your backup passphrase, and then chroot into your main system in order to fix things.


