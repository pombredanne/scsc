#!/bin/bash

if [[ ! -d /opt/scsc ]]; then
  if [[ $(whoami) != root ]]; then
    echo "You must run this script as root (using sudo)"
    exit
  fi

  export DEBIAN_FRONTEND=noninteractive

  echo ">>> Updating package index"
  apt-get update

  echo ">>> Installing Git"
  apt-get install git

  echo ">>> Installing Chef"
  curl -L https://www.opscode.com/chef/install.sh | bash

  echo ">>> Downloading SCSC"
  git clone https://github.com/myfreeweb/scsc.git /opt/scsc

  echo ">>> Running Chef"
  cd /opt/scsc
  chef-solo -c solo.rb -j nodes/scsc.json
else
  echo "SCSC is already installed!"
  echo "Use scsc-update to update it."
  echo "If you're sure it's not installed, delete the /opt/scsc directory."
fi
