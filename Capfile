load 'deploy' if respond_to?(:namespace) # cap2 differentiator
Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
load 'config/deploy.rb'

require 'capistrano/ext/multistage'

namespace :deploy do

  # Overwritten to provide flexibility for people who aren't using Rails.
  desc "Prepares one or more servers for deployment."
  task :setup, :except => { :no_release => true } do
    dirs = [deploy_to, releases_path, shared_path]
    domains.each do |domain|
      dirs += [shared_path + "/#{domain}/files"]
    end
    dirs += %w(system).map { |d| File.join(shared_path, d) }
    run "umask 02 && mkdir -p #{dirs.join(' ')}"
  end
  
  desc "Create the vhost entry for apache"
  task :create_vhost, :roles => :web do
    configuration = "
    <VirtualHost *:80>
      ServerName  #{application}
      ServerAlias www.#{application}

      php_value memory_limit 256M

      DocumentRoot #{current_path}/#{app_root}/
      <Directory #{current_path}/#{app_root}/>
        AllowOverride All
        Allow from all
        php_value magic_quotes_gpc 0
        AddType application/x-httpd-php .php .html
      </Directory>
    </VirtualHost>"
    
    put configuration, "/etc/httpd/vhost.d/capistrano/#{short_name}.conf"
  end
  
  after "deploy:setup", 
    "deploy:create_vhost", 
    "deploy:create_settings_php",
    "deploy:create_database",
    "deploy:symlink_files",
    "deploy:restart",
    "deploy:setup_drupal_tasks",
    "deploy:setup_backup_tasks"
  
  after "deploy:create_vhost",
    "deploy:restart"
    
  after "deploy", 
    "deploy:symlink_files",
    "deploy:cacheclear",
    "deploy:cleanup"

  desc "Create settings.php in shared/config"
  task :create_settings_php, :roles => :web do
    configuration = <<-EOF
<?php
$db_url = 'mysql://#{short_name}:#{db_pass}@localhost/#{short_name}';
$db_prefix = '';
EOF
    domains.each do |domain|
      put configuration, "#{deploy_to}/#{shared_dir}/#{domain}/local_settings.php"
    end
  end
  
  desc "Create database"
  task :create_database, :roles => :db do
    # Create and gront privs to the new db user
    create_sql = "create database #{short_name};
                  grant all on #{short_name}.* to '#{short_name}'@'localhost' identified by '#{db_pass};
                  flush privileges;'"
    run "mysql -u root -p#{db_root_pass} -e \"#{create_sql}\""
  end

  desc "link file dirs and the local_settings.php to the shared copy"
  task :symlink_files, :roles => :web do
    domains.each do |domain|
    # link settings file
      run "ln -nfs #{deploy_to}/#{shared_dir}/#{domain}/local_settings.php #{release_path}/#{app_root}/sites/#{domain}/local_settings.php"
      # remove any link or directory that was exported from SCM, and link to remote Drupal filesystem
      run "rm -rf #{release_path}/sites/#{domain}/files"
      run "ln -nfs #{deploy_to}/#{shared_dir}/#{domain}/files #{release_path}/#{app_root}/sites/#{domain}/files"
    end
  end
  
  namespace :cron do
    desc "Add in the cron.php tasks"
    task :setup_drupal_tasks, :roles => :mgt do
      run "uname -a"
    end
  
    desc "Add in the backup cron tasks"
    task :setup_backup_tasks, :roles => :mgt do
      run "uname -a"
    end
  end

  # desc '[internal] Touches up the released code.'
  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{release_path}"
  end

  desc "Flush the Drupal cache system."
  task :cacheclear, :roles => :db, :only => { :primary => true } do
    domains.each do |domain|
      run "#{drush} --uri=#{domain} cache-clear all"
    end
  end

  namespace :web do
    desc "Set Drupal maintainance mode to online."
    task :enable, :roles => :web do
      domains.each do |domain|
        php = 'variable_set("site_offline", FALSE)'
        run "#{drush} --uri=#{domain} php-eval '#{php}'"
      end
    end

    desc "Set Drupal maintainance mode to off-line."
    task :disable, :roles => :web do
      domains.each do |domain|
        php = 'variable_set("site_offline", TRUE)'
        run "#{drush} --uri=#{domain} php-eval '#{php}'"
      end
    end
  end


  # Each of the following tasks are Rails specific. They're removed.
  task :migrate do
  end

  task :migrations do
  end

  task :cold do
  end

  task :start do
  end

  task :stop do
  end

  task :restart do
    sudo "/usr/sbin/apachectl graceful"
  end

end


### TODO - The backup / restore tasks are a bit rough...

desc "Download a backup of the database(s) from the given stage."
task :backup_db, :roles => :db, :only => { :primary => true } do
  domains.each do |domain|
    filename = "#{domain}_#{stage}.sql"
    run "#{drush} --uri=#{domain} sql-dump --structure-tables-key=common > ~/#{filename}"
    download("~/#{filename}", "db/#{filename}", :via=> :scp)
  end
end

desc "Upload database(s) to the given stage."
task :restore_db, :roles => :db, :only => { :primary => true } do
  domains.each do |domain|
    filename = "#{domain}_#{stage}.sql"
    upload("db/#{filename}", "~/#{filename}", :via=> :scp)
    run "#{drush} --uri=#{domain} sql-cli < ~/#{filename}"
  end
end

after "restore_db", "deploy:cacheclear"

namespace :files do 
  desc "Download a backup of the sites/default/files directory from the given stage."
  task :download, :roles => :web do
    domains.each do |domain|
      download("#{deploy_to}/#{shared_dir}/#{domain}/files", "webroot/sites/#{domain}/files")
    end
  end
end

def short_name
  application.gsub('.', '_')
end

def random_password(size = 16)
  chars = (('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0) + %w(! @ # $ % ^ & *)
  (1..size).collect{|a| chars[rand(chars.size)] }.join
end