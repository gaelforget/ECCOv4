#!/bin/bash

#export PATH=$PATH:/usr/lib64/openmpi/bin
#export LD_LIBRARY_PATH=/usr/lib64/openmpi/lib
#export MPI_INC_DIR=/usr/include/openmpi-x86_64

source ./setup_export.sh

mkdir run

cd run
ln -s ../MITgcm/mysetups/ECCO_v4_r2/build/mitgcmuv .
ln -s ../MITgcm/mysetups/ECCO_v4_r2/input/* .
ln -s ../inputs_baseline2/input*/* .
ln -s ../forcing_baseline2 .

mpiexec -np 96 ./mitgcmuv

