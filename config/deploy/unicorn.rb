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
set :drush, "cd #{app_root} ; drush"

# These facilitate local settings.php creation and db creation
set :db_pass, "%QBK#&Ks&VcY^v8q"
set :shared_dir, 'drupal/sites'

set :mysql_log_path, '/Applications/MAMP/logs/mysql_error_log.err'
set :mysql_slow_log_path, ''
set :apache_error_log_path, '/Applications/MAMP/logs/apache_error_log'
set :apache_access_log_path, ''
set :php_log_path, '/Applications/MAMP/logs/php_error.log'

namespace :drupal do
  desc "Create a new Drupal install"
  task :setup do
    system 'mkdir drupal'
    system 'cd drupal && drush -y make http://metaltoad.mtmdevel.com/metaltoad.make'
    system 'cp drupal/sites/default/default.settings.php drupal/sites/default/settings.php'
    system %Q{echo "if (file_exists('./'. conf_path() .'/local_settings.php')) {
  include_once './'. conf_path() .'/local_settings.php';
}" >> drupal/sites/default/settings.php}
    system "cap #{stage} deploy:create_settings_php"
    system "cap #{stage} db:create"
    system "open http://#{roles[:web].first.host}/install.php"
  end
  
  task :browser do 
    system "open http://#{roles[:web].first.host}/install.php"
  end
end

# TODO: This should not dump to _dev.sql
namespace :db do
  desc "Dump the current local database"
  task :dump do
    domains.each do |domain|
      filename = "#{domain}_dev.sql"
      system "#{drush} --uri=#{domain} sql-dump > ../db/#{filename}"
    end
  end
  
  desc "Compress the database dumps for committing to git"
  task :compress do
    domains.each do |domain|
      filename = "#{domain}_dev.sql"
      system "cd db && tar -cjf #{filename}.tar.bz2 #{filename} && rm #{filename}"
    end
  end
end