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

# Specify which gateway server to run cron tasks on. For non-sony this should be 70
role :mgt, "mgt70"

# Specify the IP of the F5 pool for the DB
role :f5_db, 'web12'

# The path to drush
set :drush, "cd #{current_path}/#{app_root} ; /usr/bin/php /var/lib/php/drush/drush.php"
