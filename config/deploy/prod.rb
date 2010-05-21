# Set the deployment directory on the target hosts.
set :deploy_to, "/var/www/sites/capistrano/#{application}"

# The hostnames to deploy to.
role :web, 'web12'
role :web, 'web13'

set :gateway, '66.206.88.70'

# Specify one of the web servers to use for database backups or updates.
# This server should also be running Drupal.
role :db, "web12", :primary => true
role :db, "web13"

role :mgt, "mgt71"

# The path to drush
set :drush, "cd #{current_path}/#{app_root} ; /usr/bin/php /var/lib/php/drush/drush.php"
