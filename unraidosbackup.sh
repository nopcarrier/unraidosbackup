#!/bin/bash
# Unraid OS Backup Script - v1.0

# Load settings
SETTINGS_FILE="/boot/config/plugins/unraidosbackup/settings.cfg"
[ -f "$SETTINGS_FILE" ] && source "$SETTINGS_FILE"

# Validate required settings
FLASH_DRIVE="/boot"
DATE=$(date +%Y%m%d_%H%M%S)
TMP_BACKUP="/tmp/unraid-os-backup-$DATE"
ZIP_FILE="/tmp/unraid-os-$DATE.zip"
FAILURE=0

# Rsync flash contents
mkdir -p "$TMP_BACKUP"
rsync -av "$FLASH_DRIVE/" "$TMP_BACKUP"
if [ $? -ne 0 ]; then
  /usr/local/emhttp/webGui/scripts/notify -e "Unraid OS Backup" -s "Backup Failed" -d "Rsync failed." -i "alert"
  exit 1
fi

# Zip backup
cd "$TMP_BACKUP"
zip -r "$ZIP_FILE" . > /dev/null 2>&1
if [ $? -ne 0 ]; then
  /usr/local/emhttp/webGui/scripts/notify -e "Unraid OS Backup" -s "Backup Failed" -d "Zip process failed." -i "alert"
  rm -rf "$TMP_BACKUP"
  exit 1
fi
rm -rf "$TMP_BACKUP"

# Function to copy and cleanup
backup_to_dest() {
  DEST=$1
  if [ -n "$DEST" ]; then
    mkdir -p "$DEST"
    cp "$ZIP_FILE" "$DEST/"
    if [ $? -ne 0 ]; then
      /usr/local/emhttp/webGui/scripts/notify -e "Unraid OS Backup" -s "Backup Failed" -d "Could not copy to $DEST." -i "alert"
      FAILURE=1
      return
    fi
    find "$DEST" -maxdepth 1 -type f -name "unraid-os-*.zip" -mtime +${retention:-14} -exec rm -f {} \;
  fi
}

# Backup to both destinations
backup_to_dest "$dest1"
backup_to_dest "$dest2"

# Cleanup temp zip
rm -f "$ZIP_FILE"

# Notify
if [ $FAILURE -eq 0 ]; then
  /usr/local/emhttp/webGui/scripts/notify -e "Unraid OS Backup" -s "Backup Successful" -d "Backup completed to all destinations." -i "normal"
fi

exit 0
