echo Please enter diskname:
read diskname
1="1"
mount $diskname${1} /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=mygrub --recheck
grub-mkconfig -o /boot/grub/grub.cfg
