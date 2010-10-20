# Set the deployment directory on the target hosts.
set :deploy_to, "/var/www/sites/virtual/#{application}-#{stage}"

# The hostnames to deploy to.
role :web, "#{application}-#{stage}.metaltoad.com"

# Specify one of the web servers to use for database backups or updates.
# This server should also be running Drupal.
role :db, "#{application}-#{stage}.metaltoad.com", :primary => true

# The path to drush
set :drush, "cd #{current_path}/#{app_root} ; /usr/bin/php /data/lib/php/drush/drush.php"

set :mysql_log_path, '/var/log/mysqld.log'
set :mysql_slow_log_path, ''
set :apache_error_log_path, '/var/log/httpd/error_log'
set :apache_access_log_path, '/var/log/httpd/access_log'
set :php_log_path, '/var/log/httpd/php_error.log'