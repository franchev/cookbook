#!/bin/sh
sudo puppet apply /home/vagrant/cookbook/manifests/site.pp --modulepath=/home/vagrant/cookbook/modules $*
