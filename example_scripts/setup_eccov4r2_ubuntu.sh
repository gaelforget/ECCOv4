#!/bin/bash

if [ 0 == 1 ]; then
sudo apt install cvs
sudo apt install bc
sudo apt install make
sudo apt install gcc
sudo apt install gfortran
sudo apt install libmpich-dev
sudo apt install libnetcdf-dev
fi

#-------------

if [ 0 == 1 ]; then
export CVSROOT=':pserver:cvsanon@mitgcm.org:/u/gcmpack'
cvs login 
cvs co -P MITgcm_verif_basic
fi

if [ 0 == 1 ]; then
export MPI_INC_DIR=/usr/include/mpi/
cd MITgcm/verification/
./testreport -of ../tools/build_options/linux_amd64_gfortran -MPI 2 -t ideal_2D_oce
cd ../..
fi

#-------------

if [ 0 == 1 ]; then
export CVSROOT=':pserver:cvsanon@mitgcm.org:/u/gcmpack'
cd MITgcm/verification/
cvs login
cvs co -P -d global_oce_cs32 MITgcm_contrib/verification_other/global_oce_cs32

cd global_oce_cs32
ln -s code code_ad
wget ftp://mit.ecco-group.org/ecco_for_las/version_4/checkpoints/core2_cnyf.tar
tar xf core2_cnyf.tar
\rm -f core2_cnyf.tar
cd ../../..
fi

if [ 0 == 1 ]; then
export MPI_INC_DIR=/usr/include/mpi/
cd MITgcm/verification/
./testreport -of ../tools/build_options/linux_amd64_gfortran -MPI 2 -t global_oce_cs32
cd ../..
fi

#-------------

if [ 0 == 1 ]; then
mkdir MITgcm/mysetups
cd MITgcm/mysetups

export CVSROOT=':pserver:cvsanon@mitgcm.org:/u/gcmpack'
cvs login
cvs co -P -d ECCO_v4_r2 MITgcm_contrib/gael/verification/ECCO_v4_r2

cd ECCO_v4_r2/input_fields/
./gunzip_files
cd ../../../..
fi

if [ 0 == 1 ]; then
mkdir MITgcm/mysetups
cd MITgcm/mysetups

git clone https://github.com/gaelforget/ECCO_v4_r2

cd ECCO_v4_r2
mkdir run
wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/input_init/
mv mit.ecco-group.org/ecco_for_las/version_4/release2/input_init input_fields
cd ../../..
fi

#-------------------

if [ 0 == 1 ]; then
cd MITgcm/mysetups/ECCO_v4_r2
wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/input_forcing/
wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/input_ecco/
mv mit.ecco-group.org/ecco_for_las/version_4/release2/input_forcing forcing_baseline2
mv mit.ecco-group.org/ecco_for_las/version_4/release2/input_ecco inputs_baseline2
cd ../../..
fi

#-------------------

if [ 0 == 1 ]; then
cd MITgcm/mysetups/ECCO_v4_r2/build
../../../tools/genmake2 -mods=../code -optfile \
../../../tools/build_options/linux_amd64_gfortran -mpi
make depend
make -j 4

cd ../run
ln -s ../build/mitgcmuv .
ln -s ../input/* .
ln -s ../input_fields/* .
ln -s ../inputs_baseline2/input*/* .
ln -s ../forcing_baseline2 .

#mpiexec -np 96 ./mitgcmuv

cd ../../../..
fi



