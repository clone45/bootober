# ------------------------------------------------------------------------------
#  provision.sh
# ------------------------------------------------------------------------------
#
# Usage:
#
# provision.sh [sitename]
#
# Good example values for SITE:
#
#   postalmonkey
#   instacash
#   phustr
#   pigglybonk
#
# This script was created for my own use to automate the provisioning of a local 
# Vagrant development environment for website development using the Laravel 
# October CMS.  It's intended to be run on Windows.
#
# What it does:
#
#   Installs and configures Apache
#   Installs PHP5
#   Installs MySQL
#   Installs Git
#   Installs Composer
#   Installs October
#   Installs Grunt
#   Adds the project to Bitbucket
#
# Before running, set variables in config.sh
#

if [ ! $# -eq 1 ]
  then
    echo "usage: provision.sh [sitename]"
    exit 0
fi

# Load configuration
SITE=$1
source config.sh

# Find the current working directory
DIR=`pwd`
DIR=$(echo "$DIR" | sed 's/^\///' | sed 's/^./\0:/')

# Remove any old files
if [ -f Vagrantfile ]; then
  rm Vagrantfile
fi

if [ -f bootstrap.sh ]; then
  rm bootstrap.sh
fi

# Create the vagrant file and inject the configuration variables
cat > Vagrantfile << EOF
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/precise32"
  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.network "private_network", ip: "$BIND_ADDRESS"
  config.vm.synced_folder "$DIR/www", "/var/www/$SITE"
end
EOF

sed "s/\$site/$SITE/g;s/\$github_token/$GITHUB_TOKEN/g;
     s/\$bind_address/$BIND_ADDRESS/g
     s/\$bitbucket_login/$BITBUCKET_LOGIN/g
     s/\$bitbucket_password/$BITBUCKET_PASSWORD/g" <bootstrap.prototype >bootstrap.sh

if [ ! -d "www" ]; then
  mkdir www
fi

eval "vagrant up"
