<?php

try{
	$types = _node_types_build()->types;
}catch(Exception $e){
	$types = node_get_types();
}

$views = views_get_all_views();

$modules=module_list();

/*
 * this is neat, too:
 * module_load_include('inc', 'update', 'update.compare');
 * $projects=update_get_projects();
 * 
 */