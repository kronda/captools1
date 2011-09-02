# Set the deployment directory on the target hosts.
set :deploy_to, "/var/www/sites/capistrano/#{application}"

# The hostnames to deploy to.
role :web, 'web12'

set :gateway, '66.206.88.71'

# Specify one of the web servers to use for database backups or updates.
# This server should also be running Drupal.
role :db, "web12", :primary => true

# The path to drush
set :drush, "cd #{current_path}/#{app_root} ; /usr/local/bin/drush"

# The username on the target system, if different from your local username
ssh_options[:user] = 'deploy'