# TODO: Check that files directory links to /var/www/files
# TODO: Add drupal/backup cron tasks to mgt server
# TODO: Review db pull/push (perhaps use taps?)
# TODO: Add db download (pull without the auto-restore)
# TODO: Add file pull/push
# TODO: Find a way to make create_settings_php and db:create isolatable
# TODO: Vhost should turn off overrides and create the vhost entry correctly
# TODO: Add logs command
# TODO: Add email settings to vhost
# TODO: Check vhost file into svn
# TODO: Add SSL Support
# TODO: Add VirtualDocumentRoot settings
# TODO: Document the password used during setup so that we can change that in the stage's deploy recipe
# TODO: apache restart should try doing a -t before continuing
# TODO: setup consistent deployment user w/ deploy keys
# TODO: chmod ug+rw -R #{app_root} after deploy
# TODO: add release maintenance, keep 10 copies
# TODO: for prod: disable devel modules, enable css/js/page caches, disable theme auto-rebuild
# TODO: What's supposed to happen for multi-site deployments?
# TODO: Setup multisite for create_vhost
# TODO: Make database user configurable
# TODO: Add a password reset function to maint namespace
# TODO: Add a 'make me an admin' function to maint namespace
# TODO: Create an export task to take the db, files, code and package them into a tarball

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
  
  after "deploy:setup", 
    "deploy:create_settings_php",
    "db:create",
    "deploy:create_vhost", 
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
    domains.each do |domain|
      configuration = <<-EOF
<?php
$db_url = 'mysql://#{tiny_name(domain)}:#{db_pass}@#{f5_db ||= "localhost"}/#{short_name(domain)}';
$db_prefix = '';
EOF
      put configuration, "#{deploy_to}/#{shared_dir}/#{domain}/local_settings.php"
    end
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

  task :restart, :roles => :web do
  end

end


### TODO - The backup / restore tasks are a bit rough...

namespace :db do
  desc "Download a backup of the database(s) from the given stage."
  task :download, :roles => :db, :only => { :primary => true } do
    domains.each do |domain|
      filename = "#{domain}_#{stage}.sql"
      run "#{drush} --uri=#{domain} sql-dump --structure-tables-key=common > ~/#{filename}"
      download("~/#{filename}", "db/#{filename}", :via=> :scp)
    end
  end
  
  desc "Download and apply a backup of the database(s) from the given stage."
  task :pull, :roles => :db, :only => { :primary => true } do
    domains.each do |domain|
      filename = "#{domain}_#{stage}.sql"
      run "#{drush} --uri=#{domain} sql-dump --structure-tables-key=common > ~/#{filename}"
      download("~/#{filename}", "db/#{filename}", :via=> :scp)
      system "cd #{app_root} ; drush --uri=#{domain} sql-cli < ../db/#{filename}"
    end
  end

  desc "Upload database(s) to the given stage."
  task :push, :roles => :db, :only => { :primary => true } do
    domains.each do |domain|
      filename = "#{domain}_#{stage}.sql"
      upload("db/#{filename}", "~/#{filename}", :via=> :scp)
      run "#{drush} --uri=#{domain} sql-cli < ~/#{filename}"
    end
  end
  
  desc "Create database"
  task :create, :roles => :db, :only => { :primary => true } do
    # Create and gront privs to the new db user
    domains.each do |domain|
      create_sql = "CREATE DATABASE IF NOT EXISTS #{short_name(domain)} ;
                    GRANT ALL ON #{short_name(domain)}.* TO '#{tiny_name(domain)}'@'localhost' IDENTIFIED BY '#{db_pass}';
                    FLUSH PRIVILEGES;"
      run "mysql -u root -p#{db_root_pass} -e \"#{create_sql}\""
    end
  end
end

namespace :maint do
  desc "Send the root password reset to your email box."
  task :root_reset, :roles => :db, :only => { :primary => true } do
    select_sql = "SELECT mail FROM users WHERE uid=1"
    # store old mail here
    change_sql = "UPDATE users SET mail='#{Capistrano::CLI.password_prompt("Your email: ")}' WHERE uid=1"
    # send password reset mail here
    revert_sql = "UPDATE users SET mail='#{mail}' WHERE uid=1"
    
    domains.each do |domain|
      # Use drush to update each domain
    end
  end
  
  desc "Make yourself an admin account on each domain"
  task :make_me_admin, :roles => :db, :only => { :primary => true } do
    
    domains.each do |domain|
      # Use drush to update each domain
    end
  end
end

after "db:push", "deploy:cacheclear"

namespace :logs do
  desc "Pull down the apache error logs"
  task :apache, :roles => :web do
    domains.each do |domain|
      
    end
  end
  
  desc "Pull down the mysql logs"
  task :mysql, :roles => :db, :only => { :primary => true } do
    domains.each do |domain|
      
    end
  end
  
  desc "Pull down the php error logs"
  task :php, :roles => :web do
    
  end
end

namespace :files do 
  desc "Download a backup of the sites/default/files directory from the given stage."
  task :pull, :roles => :web do
    domains.each do |domain|
      download("#{deploy_to}/#{shared_dir}/#{domain}/files", "webroot/sites/#{domain}/files")
    end
  end
  
  desc "Push a backup of the sites/default/files directory from the given stage."
  task :push, :roles => :web do
    
  end
end

def short_name(domain=nil)
  return "#{application}_#{domain}".gsub('.', '_')[0..63] if domain && domain != 'default'
  return application.gsub('.', '_')[0..63]
end

def tiny_name(domain=nil)
  return "#{application[0..7]}_#{domain[0..6]}".gsub('.', '_') if domain && domain != 'default'
  return application.gsub('.', '_')[0..15]
end

def random_password(size = 16)
  chars = (('A'..'Z').to_a + ('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0) + %w(! @ # $ % ^ & *)
  (1..size).collect{|a| chars[rand(chars.size)] }.join
end