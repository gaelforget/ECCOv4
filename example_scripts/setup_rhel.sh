#!/bin/bash

#apply system updates
sudo yum -y update

#install compiler and other tools
sudo yum -y install cvs
sudo yum -y install git
sudo yum -y install bc
sudo yum -y install make
sudo yum -y install wget
sudo yum -y install gcc
sudo yum -y install gcc-gfortran
#sudo yum -y install mpich
sudo yum -y install openmpi-devel

#install netcdf via Extra Packages for Enterprise Linux (EPEL)
if [ ! -e epel-release-6-8.noarch.rpm ]; then
wget https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
else
sleep 10
fi
sudo rpm -i epel-release-6-8.noarch.rpm
sudo yum -y install netcdf-devel

#define environment variables needed to run MITgcm
if [ ! -e setup_export.sh ]; then
{
  echo '#!/bin/bash'
  echo 'export PATH=$PATH:/usr/lib64/openmpi/bin'
  echo 'export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib'
  echo 'export MPI_INC_DIR=/usr/include/openmpi-x86_64'
} > setup_export.sh
fi

