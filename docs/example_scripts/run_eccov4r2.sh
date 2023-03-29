#!/bin/bash

#export PATH=$PATH:/usr/lib64/openmpi/bin
#export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib
#export MPI_INC_DIR=/usr/include/openmpi-x86_64

cd /shared
source ./setup_export.sh

mkdir /shared/run
cd /shared/run
ln -s ../MITgcm/mysetups/ECCOv4/build/mitgcmuv .
ln -s ../MITgcm/mysetups/ECCOv4/input/* .
ln -s ../inputs_baseline2/input*/* .
ln -s ../forcing_baseline2 .

mpiexec -np 96 ./mitgcmuv

