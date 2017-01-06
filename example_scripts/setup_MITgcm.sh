#!/bin/bash

#install MITgcm
echo '/1 :pserver:cvsanon@mitgcm.org:2401/u/gcmpack Ah<Zy=0=' > ~/.cvspass
export CVS_RSH=ssh
cvs -Q -d :pserver:cvsanon@mitgcm.org:/u/gcmpack co MITgcm_verif_basic

#install ECCO v4 r2 setup
mkdir MITgcm/mysetups
cd MITgcm/mysetups
git clone https://github.com/gaelforget/ECCO_v4_r2
mkdir ECCO_v4_r2/run
wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/input_init/
mv mit.ecco-group.org/ecco_for_las/version_4/release2/input_init ECCO_v4_r2/input_fields
cd ../..

#compile and run short MITgcm test
cd MITgcm/verification/
./testreport -of ../tools/build_options/linux_amd64_gfortran -MPI 2 -t ideal_2D_oce
cd ../..

#compile ECCO v4 r2 setup
cd MITgcm/mysetups/ECCO_v4_r2/build
../../../tools/genmake2 -mods=../code -optfile ../../../tools/build_options/linux_amd64_gfortran -mpi
make depend
make -j 4

