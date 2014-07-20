## Analyze Your Drupal Migration

This will analyze your Drupal project, so you have a good list of what you need to upgrade/implement from an existing running Drupal site.

For example, you have a Drupal 6 site, and you want to upgrade to Drupal 7. Part of spec'ing out the project is that you need to document the content-types, views, and installed modules. This will generate a TSV (importable to spreadsheet) and markdown file describing what is setup. Markdown is the readme format used by github, and can easily be converted to HTML using [markdown CLI].

[markdown CLI]: http://daringfireball.net/projects/markdown/

Feel free to make more output scripts. Use my md/tsv files as an example. The whole thing is trivially simple.
 
### Use it like this!

cd to the site's folder (if multisites) or the top-level Drupal root. Basically wherever you do drush operations for that site.

run the command like this:

`
LOCATION_OF_DOCUMENT_FILES/site_analyzer_md > ~/yernewplan.md
`

or

`
LOCATION_OF_DOCUMENT_FILES/site_analyzer_tsv > ~/yernewplan.tsv
`
