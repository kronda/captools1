<?php
// Add tables to structure-only list
// Set default if it doesn't exist. Copied from example.drushrc.php
if (!isset($options['structure-tables']['common'])) {
  $options['structure-tables']['common'] = array('cache', 'cache_filter', 'cache_menu', 'cache_page', 'history', 'sessions', 'watchdog');
}

/**
 * These are the defaults for the majority of projects at Metal Toad. Add or
 * remove tables as needed.
 */
$options['structure-tables']['common'] = array_merge($options['structure-tables']['common'], array(
  'cache_admin_menu',
  'cache_block',
  'cache_field',
  'cache_form',
  'cache_path',
  'cache_token',
  'cache_update',
  'cache_views',
  'cache_views_data',
  'ctools_css_cache',
  'ctools_object_cache',
));

/**
 * If you use Drupal core search, you can uncomment this section to exclude
 * the search index tables.
 */
/*
// Add option to download search tables if you really want
$options['structure-tables']['search'] = $options['structure-tables']['common'];

// By default don't download the search index tables though
$options['structure-tables']['common'] = array_merge($options['structure-tables']['common'], array(
  'search_dataset',
  'search_index',
  'search_node_links',
  'search_total',
));
*/
