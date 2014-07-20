#!/usr/bin/env drush scr
<?php
// creates markdown to describe the site
// run in the sites directory

require_once('site_analyzer.php');

?>
# <?php echo variable_get('site_name', 'Site Report'); ?>

## Content-types

<?php

foreach($types as $type_name=>$type){
	print "###{$type->name}\n\n";
	print "{$type->description}\n\n";
}
?>


## Views

<?php
foreach($views as $view_name=>$view){
	print "### $view_name\n\n";
	if (!empty($view->description)){
		print "{$view->description}\n\n";
	}
	foreach($view->display as $display_name=>$display){
		print "* $display_name (" . $display->display_plugin . ")\n";
	}
	print "\n\n";
}
?>

## Enabled Modules

<?php
foreach($modules as $module){
	$path = drupal_get_path('module', $module) . '/' . $module . '.info';
	$info = drupal_parse_info_file($path);
	print "### " . $info['name']."\n\n";
	if ($info['description']){
		print  $info['description']."\n\n";
	}
}

?>

