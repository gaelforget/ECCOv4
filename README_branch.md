
# Branch Specific Instructions:

### 1. To Run The Model On Pleiades Super-Computer:

~~~~
git clone --branch cube92 git://gud.mit.edu/gud-dev
git clone --branch llc90drwn3 https://github.com/gaelforget/ECCO_v4_r2

mv gud-dev MITgcm
mkdir MITgcm/mysetups
mv ECCO_v4_r2/ MITgcm/mysetups/llc90drwn3

cd MITgcm/
cp -p tools/build_options/linux_amd64_ifort+mpi_ice_nas .
#uncomment the two 'mcmodel=medium' lines in linux_amd64_ifort+mpi_ice_nas
#execute the 'module load ...' line from linux_amd64_ifort+mpi_ice_nas

cd mysetups/llc90drwn3/
#either soft link the following directories to this location: 
#    inputs_baseline2, inputs_llc90drwn3, era-interim, and forcing
#or edit the following path variables accordingly:
setenv inputs_baseline2 $PWD"/inputs_baseline2/"
setenv inputs_llc90drwn3 $PWD"/inputs_llc90drwn3/"
setenv forcing_era $PWD"/era-interim/"
setenv forcing_gud $PWD"/forcing/"

cd build/
../../../tools/genmake2 -mods ../code -of ../../../linux_amd64_ifort+mpi_ice_nas
make depend
make -j9 > make.log
cd ..

mkdir run
cd run
cp -p ../build/mitgcmuv .
ln -s ../input/* .
ln -s $inputs_llc90drwn3/* .
ln -s $inputs_baseline2/input_init/* .
ln -s $inputs_baseline2/input_insitu/* .
ln -s $inputs_baseline2/input_other/* .
ln -s $forcing_era ./era-interim
ln -s $forcing_gud ./forcing

#execute the following command via adequate submission script:
mpiexec -np 96 dplace -s1 ./mitgcmuv
~~~~

### 1.1 To Run The Model On A different Cluster:

Edit the above instructions that involve `linux_amd64_ifort+mpi_ice_nas`, `module`, or `mpiexec` as needed.

### 2. To Plot Model Results:

Download gcmfaces toolbox, start Matlab, and execute `example_branch` as shown hereafter:

~~~~
git clone https://github.com/gaelforget/gcmfaces
matlab -nodesktop -nosplash
>> p = genpath('gcmfaces/'); addpath(p); %this activates the toolbox
>> addpath ../example_scripts/; %expected path to example_branch.m
>> help example_branch; %this provides documentation
>> example_branch; %this generates a few pictures
~~~~

# For Additional Documentation, See:

* [upstream ECCOv4 setup repository](https://github.com/gaelforget/ECCO_v4_r2/ "ECCO_v4_r2/")
* [upstream ECCOv4 setup documentation](https://eccov4.readthedocs.io/en/latest/ "eccov4.readthedocs.io")
* [MIT Darwin Project documentation](http://darwinproject.mit.edu/research/ "darwinproject.mit.edu")

