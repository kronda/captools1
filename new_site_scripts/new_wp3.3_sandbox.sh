# new_site.sh
# Last edited: Chris Svajlenka, 1/4/2012
# --------------
# This script build a default Drupal install on your local machine and deploys it to our dev/staging server
# It assumes Mac OS X and requires the following to be installed on your local machine:
#
# * git
# * ruby
# * capistrano
# * MAMP or LAMP stack
#
# Additionally it requires you to have a Github account and have created a repository for your project

# Edit this line if you want to install on a machine other than mole
# export machine='unicorn' # <sitename>.<machinename>.metaltoad.com

# Prompt for the machine name
echo "Enter your machine name (vanity url for the MTM office such as 'unicorn' in 'unicorn.mtmdevel.com')"
read machinename

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

# echo "Which github context would you like to use (default: metaltoad)?"
# read gitcontext # NO DASHES, ONLY UNDERSCORES
#
# # override a blank entry with the default
# if [ ${#gitcontext} -lt 1 ]
#   then
#     gitcontext="metaltoad"
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

# Create the directory structure on your local machine
mkdir $dbname
cd $dbname
git init
#git remote
#addint the base profile to our repository.
git remote add other git@github.com:metaltoad/basewp.git  #the base WP profile
git fetch other
git checkout -b ZZZ other/master
git checkout master                # should add ZZZ to master
git commit
git remote rm other



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
mysql -u $mysqlUser -p$mysqlPass -e "CREATE DATABASE $dbname; GRANT ALL ON
$dbname.* TO '$dbuser'@'localhost' IDENTIFIED BY '$dbpassword'; GRANT ALL ON $dbname.*
TO '$dbuser'@'%'  IDENTIFIED BY '$dbpassword'; FLUSH PRIVILEGES;"
echo "Local database and user created"

# Edit your settings.php on your local machine
#cp drupal/sites/default/default.settings.php drupal/sites/default/settings.php
#chmod u+w drupal/sites/default/settings.php

# Add to the bottom of settings.php
#echo "if (file_exists('./'. conf_path() .'/local_settings.php')) {
#  include_once './'. conf_path() .'/local_settings.php';
#}" >> drupal/sites/default/settings.php

# Add your local settings
echo "<?php

  define('DB_NAME', '$dbname');

  /** MySQL database username */
  define('DB_USER', '$dbuser');

  /** MySQL database password */
  define('DB_PASSWORD', '$dbpassword');

  /** MySQL hostname */
  define('DB_HOST', 'localhost');
" > wordpress/local-config.php

# Add entries to .gitignore
echo "wordpress/wp-content/uploads
wordpress/wp-content/w3tc
wordpress/wp-content/avatars
wordpress/wp-content/cache
wordpress/wp-content/local-config.php
.buildpath
.project
.settings
db
*~
.DS_Store
" > .gitignore

# Edit .htaccess to uncomment the line if you use VirtualDocumentRoot
perl -pi -e 's/# RewriteBase \/$/RewriteBase \//' wordpress/.htaccess


# Final commit
git add .
git commit -am "initial commit of wordpress"
# git remote add origin git@github.com:$gitcontext/$dbname.git
# git push origin master

# Your local site is now ready for you to hit the /wp-admin/install.php wordpress file
# From here down we're setting things up to deploy on Mole:
# -----------------------------------------------

# Modify the template to point to specific project
# perl -pi -e "s/set :application, \"xxxxx\"/set :application, \"$dbname\"/" config/deploy.rb
# perl -pi -e "s/set :githubcontext, \"metaltoad\"/set :githubcontext, \"$gitcontext\"/" config/deploy.rb

# Add the Capistrano files to git
# git add Capfile
# git add config
# git commit -m "adding capistrano stuff"
# git push origin master

# Deploy to mole
# cap deploy:setup
# cap deploy

# Install via the website/install.php

#open "http://$dbname.$machinename.mtmdevel.com/install.php"
open "http://$dbname/wp-admin/install.php"
