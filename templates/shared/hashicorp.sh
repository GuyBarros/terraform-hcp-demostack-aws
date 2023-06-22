#!/usr/bin/env bash
set -x

if [ ${enterprise} == 0 ]
then
sudo apt-get install -y \
  vault \
  consul \
  nomad  \
  &>/dev/null

else
sudo apt-get install -y \
  vault-enterprise \
  consul-enterprise \
  nomad-enterprise  \
  &>/dev/null

fi
