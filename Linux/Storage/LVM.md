# Work with LVM

## Create a volume and create a LVM on it

```bash
fdisk /dev/sdb
pvcreate /dev/sdb1
vgcreate VG-sdb1 /dev/sdb1
lvcreate -l 100%FREE -n LV-db-data VG-sdb1
mkfs.ext4 /dev/mapper/VG--sdb1-LV--db--data
mkdir /mnt/db-data 
mount /dev/mapper/VG--sdb1-LV--db--data /mnt/db-data
ls -la /dev/disk/by-uuid/
vim /etc/fstab
/dev/disk/by-uuid/559676f7-2d1e-404d-a7fd-ac6edbe1ada4 /mnt/db-data ext4 defaults 0 0
```

## Extend existing LVM

```bash
# prepare
#     know, which of PhisicalDisk you need to resize? For example /dev/sda3 (pvdisplay)
#     know, which of VolumeGroup you need to extend? For example VG-sda (vgdisplay)
#     know, which of LogicalVolume you need to extend? For example /dev/VG-sda/LV-root (lvdisplay)

pvdisplay
pvresize /dev/sda3
vgdisplay
vgextend VG-sda
lvdisplay
lvextend -l +100%FREE /dev/VG-sda/LV-root
resize2fs /dev/VG-sda/LV-root
df -Th
```
