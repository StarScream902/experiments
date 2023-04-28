# Reread a disk amount if you add it on fly

```bash
# Scan all attached devices

echo "---" | sudo tee /sys/class/scsi_host/host${BUS_NUMBER}/scan

# Reread a disk size without restart

echo 1 > /sys/block/sda/device/rescan

parted -l

partprobe -s or restart if not helped
```
