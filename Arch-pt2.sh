#!bin/bash
echo Please type your diskname
read diskname
echo Please type your region
ls /usr/share/zoneinfo/
read region
echo Please select city
ls /usr/share/zoneinfo/$region/
read city
ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc
sed -i '177 s/^##*//' /etc/locale.gen 
locale-gen
echo "LANG=en_US.UTF-8" >> locale.conf
echo Enter your hostname
read hostname
echo $hostname >> /etc/hostname
echo "127.0.0.1          localhost
::1                localhost
127.0.1.1          $hostname.localdomain     $hostname" >> /etc/hosts

echo Please set root password
passwd
echo Enter username
read username
useradd -m $username
echo Enter password for user
passwd $username
usermod -aG wheel,audio,video,optical,storage $username
pacman -S sudo
sed -i '82 s/^##*//' /etc/sudoers
pacman -S grub
pacman -S dosfstools efibootmgr mtools os-prober
mkdir /boot/EFI
./Arch-pt3.sh
pacman -S networkmanager
systemctl enable NetworkManager
echo Run umount -l /mnt and reboot.
echo Hope this helped.
exit

