#!/bin/bash

#export PATH=$PATH:/usr/lib64/openmpi/bin
#export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib
#export MPI_INC_DIR=/usr/include/openmpi-x86_64

cd /shared
source ./setup_export.sh

cd /shared/MITgcm/verification/ideal_2D_oce/run
mpiexec -np 2 ./mitgcmuv

