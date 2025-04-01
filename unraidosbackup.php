<?php
// File: /usr/local/emhttp/plugins/unraidosbackup/unraidosbackup.php

$cfgFile = "/boot/config/plugins/unraidosbackup/settings.cfg";

// Handle POST requests
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  // Run backup now
  if (isset($_POST['run_backup'])) {
    exec("/usr/local/emhttp/plugins/unraidosbackup/unraidosbackup.sh > /dev/null 2>&1 &");
    echo "Backup started!";
    exit;
  }

  // Save settings
  $dest1 = escapeshellarg($_POST['dest1'] ?? '');
  $dest2 = escapeshellarg($_POST['dest2'] ?? '');
  $retention = escapeshellarg($_POST['retention'] ?? '14');
  $schedule = escapeshellarg($_POST['schedule'] ?? 'daily');

  file_put_contents($cfgFile, "dest1=$dest1\n");
  file_put_contents($cfgFile, "dest2=$dest2\n", FILE_APPEND);
  file_put_contents($cfgFile, "retention=$retention\n", FILE_APPEND);
  file_put_contents($cfgFile, "schedule=$schedule\n", FILE_APPEND);

  echo "Settings saved!";
  exit;
}

// Handle GET (load settings)
$settings = @parse_ini_file($cfgFile);
echo json_encode($settings);
