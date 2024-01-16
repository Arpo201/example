# Just 1 time after initialization disk
sudo mkdir -p /mnt/disks/data
sudo mount -o discard,defaults /dev/disk/by-id/google-data /mnt/disks/data
sudo chmod a+w /mnt/disks/data

# sudo mkdir -p /mnt/disks/data/etc && sudo cp -pr /etc /mnt/disks/data
# sudo mkdir -p /mnt/disks/data/var/lib && sudo cp -pr /var/lib /mnt/disks/data/var

# sudo mount --bind /mnt/disks/data/etc /etc
# sudo mount --bind /mnt/disks/data/var/lib /var/lib

