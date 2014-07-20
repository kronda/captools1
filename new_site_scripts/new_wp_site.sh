# new_wp_site.sh
# Last edited: Kronda Adair, 02/16/2013
# --------------
# This script creates a new local Wordpress install on your local machine and creates a database to go with it.
# It assumes Mac OS X and requires the following to be installed on your local machine:
#
# * git
# * ruby
# * capistrano
# * MAMP or LAMP stack
#
# Additionally it requires you to have a Github account and have created a repository for your project

# Prompt for the site name
echo "Enter the site name, no dashes or spaces"
read dbname # NO DASHES, ONLY UNDERSCORES


# truncate the dbuser name to 16 characters (MySQL restriction)
dbuser=$dbname
if [ ${#dbuser} -gt 15 ]
  then
    dbuser=${dbuser:0:16}
    echo "The username for the database is being truncated to $dbuser (16 characters)"
fi

# echo "Which github context would you like to use (default: kronda)?"
# read gitcontext # NO DASHES, ONLY UNDERSCORES
#
# # override a blank entry with the default
# if [ ${#gitcontext} -lt 1 ]
#   then
#     gitcontext="kronda"
#     echo "Using $gitcontext as github context"
# fi

echo "Enter your local MySQL superuser name and password (format: name pass) (default: root root)"
read mysqlUser mysqlPass

if [ ${#mysqlUser} -lt 1 ]
  then
    mysqlUser="root"
    mysqlPass="root"
    echo "Using $mysqlUser $mysqlPass for local MySQL root access"
fi

echo "Enter the branch you would like to use (make or master, defaults to master)"
read branch
branch=$branch

if [ ${#branch} -lt 1 ]
  then
    branch="master"
    echo "Using branch $branch from repo"
fi

# Create the directory structure on your local machine
mkdir $dbname
cd $dbname
git init
#git remote
#addint the base profile to our repository.
git remote add other git@github.com:kronda/basewp.git  #the base WP profile
git fetch other
git checkout -b ZZZ other/$branch
git checkout $branch                # should add ZZZ to master
git commit
git remote rm other
git branch -D ZZZ
git checkout -b master
git remote add origin git@github.com:kronda/$dbname.git


# Generate a nice password for the db
export dbpassword=`echo '<?php
 $length = 8;
 $pass = '';
    srand((float) microtime() * 10000000);
    for ($i = 0; $i < $length; $i++) {
        $pass .= chr(rand(32, 126));
    }
print($pass);' | php`

# Create the database and add grant rights on your local machine
echo "Creating local database & user..."
mysql -u $mysqlUser -p$mysqlPass -e "CREATE DATABASE $dbname; GRANT ALL ON $dbname.* TO '$dbuser'@'localhost' IDENTIFIED BY '$dbpasswor'; GRANT ALL ON $dbname.* TO '$dbuser'@'%' IDENTIFIED BY '$dbpassword'; FLUSH PRIVILEGES;"
echo "Local database and user created"

# Add to the bottom of settings.php
#echo "if (file_exists('./'. conf_path() .'/local_settings.php')) {
#  include_once './'. conf_path() .'/local_settings.php';
#}" >> drupal/sites/default/settings.php

# Add your local settings
echo "<?php

  define('DB_NAME', '$dbname');

  /** MySQL database username */
  define('DB_USER', '$mysqlUser');

  /** MySQL database password */
  define('DB_PASSWORD', '$mysqlPass');

  /** MySQL hostname */
  define('DB_HOST', '127.0.0.1');
" > wordpress/local-config.php

# Add entries to .gitignore
echo "wordpress/wp-content/uploads
wordpress/wp-content/w3tc
wordpress/wp-content/avatars
wordpress/wp-content/cache
wordpress/local-config.php
.buildpath
.project
.settings
*sublime*
*.sass-cache*
*debug.log*
docs
db
*~
.DS_Store
/.gitattributes
*.sass-cache/
*.sublime*
*compass_app_log.txt*
webroot
backups
" > .gitignore

# Edit .htaccess to uncomment the line if you use VirtualDocumentRoot
perl -pi -e 's/# RewriteBase \/$/RewriteBase \//' wordpress/.htaccess

# Create a symbolic link webroot folder
ln -s wordpress webroot

# Final commit
git add -A
git commit -am "initial commit of wordpress"

git remote add origin git@github.com:$gitcontext/$dbname.git

# Your local site is now ready for you to hit the /wp-admin/install.php wordpress file
# From here down we're setting things up to deploy on Mole:
# -----------------------------------------------

# Modify the template to point to specific project
sed -e "s/karveldigital/$dbname/g" -i .bak config/deploy.rb
rm config/deploy.rb.bak
# perl -pi -e "s/set :application, \"xxxxx\"/set :application, \"$dbname\"/" config/deploy.rb
# perl -pi -e "s/set :githubcontext, \"karveldigital\"/set :githubcontext, \"$gitcontext\"/" config/deploy.rb

# Add the Capistrano files to git
# git add Capfile
# git add config
# git commit -m "adding capistrano stuff"
# git push origin master

# Deploy to mole
# cap deploy:setup
# cap deploy

# Install via the website/install.php

open "http://$dbname.kdev.com/wp-admin/install.php"
