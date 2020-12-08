#!/bin/bash

timedatectl set-ntp true
fdisk -l

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
arch-chroot /mnt
