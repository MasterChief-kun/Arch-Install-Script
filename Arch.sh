#!/bin/bash

timedatectl set-ntp true
fdisk -l
echo Please enter your Region
ls /usr/share/zoneinfo/
read region
echo Please enter your city
ls /usr/share/zoneinfo/$region/
read city
echo "Enter your hostname(Name by which you'll be identified on your network)"
read hostname
echo "Enter your username"
read username
echo "Please enter root password"
read rootpswd
echo "Please enter user password"
read upswd
echo Which Disk do you want to install Arch Linux to?
read diskname

echo Do you want wipe your disk and install Arch Linux?y/n
read wipe
echo Unallocated Space: $(parted $diskname unit GB print free)  
echo " "
echo Size of root partition IN GB
read rootpart
echo " "
echo Unallocated Space: $(parted $diskname unit GB print free) 
echo " "
echo Size of SWAP partition
read swappart
echo Unallocated Space: $(parted $diskname unit GB print free)
#totalspace=((df -P | awk 'NR>2 && /^\/dev\//{sum+=$2}END{print sum}')/(1024^2))	
#rspacep=($rootpart/$totalspace)*100
#swspacep=($swappart/$totalspace)*100
bruh=$((rootpart + swappart))
gig='G'
parted $diskname mklabel GPT

parted $diskname mkpart primary fat32 2048s 512M

parted $diskname mkpart primary ext4 512M $rootpart${gig}

parted $diskname mkpart primary linux-swap $rootpart${gig} $bruh${gig} 

parted $diskname set 1 esp on

part1="1"
part2="2"
part3="3"
mkfs.fat -F32 $diskname${part1}

mkfs.ext4 $diskname${part2}

mkswap $diskname${part3}

swapon $diskname${part3}

mount $diskname${part2} /mnt

pacstrap /mnt base linux linux-firmware vim

genfstab -U /mnt >> /mnt/etc/fstab
chmod a+x Arch-pt2.sh
cp Arch-pt2.sh /mnt/
echo "Please execute Arch-pt2.sh with "./Arch-pt2.sh""
cat << CHROOT | arch-chroot /mnt
#echo Please type your diskname
#read diskname
#echo Please type your region
#ls /usr/share/zoneinfo/
#read region
#echo Please select city
#ls /usr/share/zoneinfo/$region/
#read city
ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime
hwclock --systohc
sed -i '177 s/^##*//' /etc/locale.gen 
locale-gen
echo "LANG=en_US.UTF-8" >> locale.conf
#echo Enter your hostname
#read hostname
echo $hostname >> /etc/hostname
echo "127.0.0.1          localhost
::1                localhost
127.0.1.1          $hostname.localdomain     $hostname" >> /etc/hosts

#echo Please set root password
cat << RPSWD | passwd
$rootpswd
$rootpswd
RPSWD
#echo Enter username
#read username
useradd -m $username
#echo Enter password for user
cat >> UPSWD | passwd $username
$upswd
$upswd
UPSWD
usermod -aG wheel,audio,video,optical,storage $username
pacman -S sudo
sed -i '82 s/^##*//' /etc/sudoers
pacman -S grub
pacman -S dosfstools efibootmgr mtools os-prober
mkdir /boot/EFI
efi=${diskname}1
mount $efi /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=mygrub --recheck
grub-mkconfig -o /boot/grub/grub.cfg
pacman -S networkmanager
systemctl enable NetworkManager
echo Run umount -l /mnt and reboot.
CHROOT
