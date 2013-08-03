#!/bin/bash

if [[ ! -d /opt/scsc ]]; then
  echo ">>> Updating package index"
  sudo apt-get update

  echo ">>> Installing Git"
  sudo apt-get install --force-yes git

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
