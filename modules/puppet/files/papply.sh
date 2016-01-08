#!/bin/sh
sudo puppet apply /home/ubuntu/cookbook/manifests/site.pp --modulepath=/home/ubuntu/cookbook/modules $*
