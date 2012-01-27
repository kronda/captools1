# new_site.sh
# Last edited: Kronda Adair, 4/19/2010
# --------------
# This script build a default Drupal install on your local machine and deploys it to our dev/staging server
# It assumes Mac OS X and requires the following to be installed on your local machine:
#
# * git
# * ruby
# * capistrano
# * drush
# * MAMP or LAMP stack
#
# Additionally it requires you to have a Github account and have created a repository for your project

# Edit this line if you want to install on a machine other than mole
# export machine='unicorn' # <sitename>.<machinename>.metaltoad.com

# Prompt for the site name
echo "Enter the site/repo name, no dashes or spaces (must match github)"
read dbname # NO DASHES, ONLY UNDERSCORES

# truncate the dbuser name to 16 characters (MySQL restriction)
dbuser=$dbname
if [ ${#dbuser} -gt 15 ]
  then
    dbuser=${dbuser:0:16}
    echo "The username for the database is being truncated to $dbuser (16 characters)"
fi

echo "Which github context would you like to use (default: metaltoad)?"
read gitcontext # NO DASHES, ONLY UNDERSCORES

# override a blank entry with the default
if [ ${#gitcontext} -lt 1 ]
  then
    gitcontext="metaltoad"
    echo "Using $gitcontext as github context"
fi

echo "Enter your local MySQL superuser name and password (format: name pass) (default: root root)"
read mysqlUser mysqlPass

if [ ${#mysqlUser} -lt 1 ]
  then
    mysqlUser="root"
    mysqlPass="root"
    echo "Using $mysqlUser $mysqlPass for local MySQL root access"
fi

# Create the directory structure on your local machine
mkdir $dbname
cd $dbname
git init
mkdir docs
mkdir db
# OR
# git clone FOO

# This creates the drupal specific directory using Drush and a make file that is hosted on mole
# This make file contains information on all of the modules to be included in our default install
mkdir drupal
ln -nsf drupal webroot
cd webroot
echo 'api = 2
core = 7.x
projects[drupal] = 7x-1.x
projects[drupal][type] = core
projects[metaltoad][type] = "profile"
projects[metaltoad][download][type] = "git"
projects[metaltoad][download][url] = "git@github.com:metaltoad/metaltoad_drupal_profiles.git"
projects[metaltoad][download][revision] = "7.x"' > kickstart.make
drush -y make kickstart.make
cd ..

# Generate a nice password for the db
export dbpassword=`echo '<?php
$words = file("webroot/profiles/metaltoad/wordlist.txt");
$pass = array();
foreach (range(1, 4) as $i) {
  $pass[] = chop($words[mt_rand(0, count($words) - 1)]);
}
$pass = implode($pass, "_");
print($pass);' | php`

# Create the database and add grant rights on your local machine
echo "Creating local database & user..."
mysql -u $mysqlUser -p$mysqlPass -e "CREATE DATABASE $dbname; GRANT ALL ON
$dbname.* TO '$dbuser'@'localhost' IDENTIFIED BY '$dbpassword'; GRANT ALL ON $dbname.*
TO '$dbuser'@'%'  IDENTIFIED BY '$dbpassword'; FLUSH PRIVILEGES;"
echo "Local database and user created"

# Edit your settings.php on your local machine
cp drupal/sites/default/default.settings.php drupal/sites/default/settings.php
chmod u+w drupal/sites/default/settings.php

# Add to the bottom of settings.php
echo "if (file_exists('./'. conf_path() .'/local_settings.php')) {
  include_once './'. conf_path() .'/local_settings.php';
}" >> drupal/sites/default/settings.php

# Add your local settings
echo "<?php

\$databases['default']['default'] = array(
  'driver' => 'mysql',
  'database' => '$dbname',
  'username' => '$dbuser',
  'password' => '$dbpassword',
  'host' => 'localhost',
);" > drupal/sites/default/local_settings.php

# Add entries to .gitignore
echo "drupal/sites/default/local_settings.php
drupal/sites/*/files
drupal/sites/*/private
drupal/sites/all/modules/imagemanager/logs
drupal/sites/all/modules/filemanager/logs
.buildpath
.project
.tmproj
.settings
db
*~
compass_app_log.txt
.sass-cache
compass_generated_stylesheets
# compass generated sprites
*-s[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f].png
.DS_Store" > .gitignore

# Edit .htaccess to uncomment the line if you use VirtualDocumentRoot
perl -pi -e 's/# RewriteBase \/$/RewriteBase \//' drupal/.htaccess

# Comment out devel_themer from the profile
perl -pi -e "s/\'devel_themer\',$/\/\/ \'devel_themer\',/" drupal/profiles/metaltoad/metaltoad.profile

# remove Drupal's default .gitignore for D7 so that the settings.php file will be commited
rm drupal/.gitignore
echo "Removing default Drupal 7 .gitignore file"

# Final commit
git add .
git commit -am "initial commit of drupal"
git remote add origin git@github.com:$gitcontext/$dbname.git
git push origin master

# Your local site is now ready for you to hit the /install.php Drupal file
# From here down we're setting things up to deploy on Mole:
# -----------------------------------------------

# Add the capistrano files into the project
git clone git@github.com:metaltoad/mtm_tools.git
cp mtm_tools/mtm_capistrano_template/Capfile .
cp -Rf mtm_tools/mtm_capistrano_template/config .
rm -Rf mtm_tools

# Modify the template to point to specific project
perl -pi -e "s/set :application, \"xxxxx\"/set :application, \"$dbname\"/" config/deploy.rb
perl -pi -e "s/set :githubcontext, \"metaltoad\"/set :githubcontext, \"$gitcontext\"/" config/deploy.rb

# Add the Capistrano files to git
git add Capfile
git add config
git commit -m "adding capistrano stuff"
git push origin master

# Deploy to mole
cap deploy:setup
cap deploy

# Install via the website/install.php
open "http://$dbname-dev.metaltoad.com/install.php"
