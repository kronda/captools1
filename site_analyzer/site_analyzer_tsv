#!/usr/bin/env drush scr
<?php
// creates csv to describe the site (from a migration perspective)
// run in the sites directory

require_once('site_analyzer.php');

print "Type\tName\tDescription\n";

foreach($types as $type_name=>$type){
	print "Content-Type\t{$type->name}\t{$type->description}\n";
}

foreach($views as $view_name=>$view){
	print "View\t{$view_name}\t{$display_name}\n";
}

foreach($modules as $module){
	$path = drupal_get_path('module', $module) . '/' . $module . '.info';
	$info = drupal_parse_info_file($path);
	print "Module\t{$info['name']}\t{$info['description']}\n";
}