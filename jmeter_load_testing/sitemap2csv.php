#!/usr/bin/env php
<?php

$sitemap = new SimpleXMLElement("$argv[1]/sitemap.xml", 0, TRUE);
$fp = fopen('urls.csv', 'w');
foreach ($sitemap->url as $url) {
  $parts = parse_url($url->loc);
  fputcsv($fp, array($parts['host'], $parts['path']));
}