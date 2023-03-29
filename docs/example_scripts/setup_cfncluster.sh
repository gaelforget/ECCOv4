#!/bin/bash

#apply system updates
sudo yum -y update

#install the cfncluster software
sudo yum -y update
sudo pip install cfncluster

#get the cfncluster config file template for ECCO v4 r2
mkdir .cfncluster
cp ECCO_v4_r2/example_scripts/config.step2 .cfncluster/config

#allow cfncluster to launch instances by providing user account information
cfncluster configure

