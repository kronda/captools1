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
role :mgt, "mgt71"

# Specify the IP of the F5 pool for the DB
role :f5_db, 'web12'

# The path to drush
set :drush, "cd #{current_path}/#{app_root} ; /usr/bin/php /var/lib/php/drush/drush.php"

set :mysql_log_path, '/var/log/mysqld.log'
set :mysql_slow_log_path, ''
set :apache_error_log_path, '/var/log/httpd/error_log'
set :apache_access_log_path, '/var/log/httpd/access_log'
set :php_log_path, '/var/log/httpd/php_error.log'

namespace :deploy do
  after "deploy:setup", 
    "deploy:create_settings_php",
    "db:create",
    "deploy:create_vhost", 
    "deploy:restart",
    "deploy:setup_drupal_tasks",
    "deploy:setup_backup_tasks"
  
  desc "Create the vhost entry for apache"
  task :create_vhost, :roles => :web, :only => { :stage => :prod } do
    configuration = "
    <VirtualHost *:80>
      ServerName  #{application}
      ServerAlias www.#{application}

      DocumentRoot #{current_path}/#{app_root}/
      <Directory #{current_path}/#{app_root}/>
        AllowOverride All
        Allow from all
      </Directory>
    </VirtualHost>"
    
    put configuration, "/etc/httpd/vhost.d/capistrano/#{short_name}.conf"
  end
end