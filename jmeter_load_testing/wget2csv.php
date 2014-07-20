#!/usr/bin/env php
<?php

$site = $argv[1];

$wget = popen('wget --spider --level=3 --recursive --no-verbose --follow-tags=a --exclude-directories=/includes,/misc,/modules,/profiles,/scripts,/sites,/themes -e robots=off ' . escapeshellarg($site) . ' 2>&1', "r");
$out = fopen('urls.csv', 'w');

while ($line = fgets($wget)) {
  preg_match('/URL:([^ ]+) /', $line, $matches);
  if (!empty($matches)) {
    $url = parse_url($matches[1]);
    if (!empty($url['query'])) {
      $url['path'].= "?$url[query]";
    }
    fputcsv($out, array($url['host'], $url['path']));
  }
}