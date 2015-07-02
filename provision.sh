if [ ! $# -eq 2 ]
  then
    echo "usage: provision.sh [sitename] [github_oauth_token]"
    exit 0
fi

SITE=$1
GITHUB_TOKEN=$2

DIR=`pwd`
DIR=$(echo "$DIR" | sed 's/^\///' | sed 's/^./\0:/')
echo $DIR

if [ -f Vagrantfile ]; then
  rm Vagrantfile
fi

if [ -f bootstrap.sh ]; then
  rm bootstrap.sh
fi

cat > Vagrantfile << EOF
Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/precise32"
  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.network "private_network", ip: "192.168.50.7"
  config.vm.synced_folder "$DIR/www", "/var/www/$SITE"
end
EOF

sed "s/\$site/$SITE/g;s/\$github_token/$GITHUB_TOKEN/g" <bootstrap.prototype >bootstrap.sh

if [ ! -d "www" ]; then
  mkdir www
fi

eval "vagrant up"
