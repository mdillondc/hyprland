#!/bin/bash
# Mount vault drives and fix permissions

# Mount drives using UUIDs
udisksctl mount -b /dev/disk/by-uuid/24e9b283-d8ea-4a41-a723-cde1f04e710d 2>/dev/null || true  # vault-1
udisksctl mount -b /dev/disk/by-uuid/e9eb3403-b14b-48a1-bc57-3bd76709879f 2>/dev/null || true  # vault-2
udisksctl mount -b /dev/disk/by-uuid/f681e8ab-0911-49ff-8787-ca505e9641cc 2>/dev/null || true  # vault-1-mirror  
udisksctl mount -b /dev/disk/by-uuid/c905e5ab-1b30-47aa-90e0-4f8e1fae3832 2>/dev/null || true  # vault-2-mirror

# Give jellyfin access. Need to do this because these perms. won't survive reboot
sudo chgrp jellyfin "/run/media/${USER}/"
sudo chmod g+rX "/run/media/${USER}/"
sudo chgrp jellyfin "/run/media/${USER}/vault-1/"
sudo chmod g+rX "/run/media/${USER}/vault-1/"
sudo chgrp jellyfin "/run/media/${USER}/vault-2/"
sudo chmod g+rX "/run/media/${USER}/vault-2/"
sudo setfacl -m g:jellyfin:rx "/run/media/${USER}/"

# IMPORTANT!
# Must setup passwordless sudo for this script to work.
# 
# sudo visudo
# 
# Add to bottom:
# 
# # Jellyfin mount permissions
# your-username ALL=(ALL) NOPASSWD: /bin/chgrp
# your-username ALL=(ALL) NOPASSWD: /bin/chmod
# your-username ALL=(ALL) NOPASSWD: /usr/bin/setfacl
