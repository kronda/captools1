# For the most part this is pointless, but I do love the cap jasper db:create task.
# It's probably a bad idea though, too much can go wrong or be confusing at this point.

# Set the deployment directory on the target hosts.
set :deploy_to, "/Users/dylan/Sites/#{application}"

# The hostnames to deploy to.
role :web, "#{application}.jasper.mtmdevel.com"

# Specify one of the web servers to use for database backups or updates.
# This server should also be running Drupal.
role :db, "#{application}.jasper.mtmdevel.com", :primary => true

# The username on the target system, if different from your local username
# ssh_options[:user] = 'alice'

# The path to drush
set :drush, "cd #{current_path}/#{app_root} ; drush"

namespace :deploy do
  %w{migrate migrations cold start stop restart setup symlink symlink_files finalize_update update_code update}.each do |name|
    task name do; end
  end
end