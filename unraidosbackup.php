<?php
// File: /usr/local/emhttp/plugins/unraidosbackup/unraidosbackup.php

$cfgFile = "/boot/config/plugins/unraidosbackup/settings.cfg";

// Save settings
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
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

// Load settings
$settings = @parse_ini_file($cfgFile);
echo json_encode($settings);
