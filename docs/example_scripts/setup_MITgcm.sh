#!/bin/bash

if [ ! -e MITgcm ]; then

#update software if needed and generate setup_export.sh
source ./ECCO_v4_r2/docs/example_scripts/setup_rhel.sh

#define environment variables that MITgcm relies on
source ./setup_export.sh

#install MITgcm
echo '/1 :pserver:cvsanon@mitgcm.org:2401/u/gcmpack Ah<Zy=0=' > ~/.cvspass
export CVS_RSH=ssh
cvs -Q -d :pserver:cvsanon@mitgcm.org:/u/gcmpack co MITgcm_verif_basic

#install ECCO v4 r2 setup
mkdir MITgcm/mysetups
cd MITgcm/mysetups
git clone https://github.com/gaelforget/ECCO_v4_r2
mkdir ECCO_v4_r2/run
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
cd ../../../..

#display license
echo " "
echo " "
cat MITgcm/LICENSE.txt
echo " "

fi

