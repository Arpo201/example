sudo su
cp /etc/fstab /etc/fstab.backup
UUID=$(blkid /dev/disk/by-id/google-data | awk -F'"' '{print $2}')
echo "UUID=$UUID /mnt/disks/data xfs discard,defaults 0 2" >> /etc/fstab