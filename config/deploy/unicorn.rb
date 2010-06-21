# Set the deployment directory on the target hosts.
set :deploy_to, "/Users/vosechu/mtm/#{application}"

# The hostnames to deploy to.
role :web, "#{application}.unicorn.mtmdevel.com"

# Specify one of the web servers to use for database backups or updates.
# This server should also be running Drupal.
role :db, "#{application}.unicorn.mtmdevel.com", :primary => true

# The username on the target system, if different from your local username
# ssh_options[:user] = 'alice'

# The path to drush
set :drush, "cd #{current_path}/#{app_root} ; drush"