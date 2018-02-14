
To set up MITgcm to reproduce the ECCO version 4 release 3 solution, directions provided at [http://eccov4.readthedocs.io/]() should be modified as follows:


### install MITgcm + configuration

```
git clone https://github.com/MITgcm/MITgcm
git clone -b release3 https://github.com/gaelforget/ECCOv4
mkdir MITgcm/mysetups
mv ECCOv4 MITgcm/mysetups/.
```

### compile the MITgcm config.

```
cd MITgcm/mysetups/ECCOv4/build
../../../tools/genmake2 -mods=../code -optfile \
     ../../../tools/build_options/linux_amd64_gfortran -mpi
make depend
make -j 4
cd ..
```

### download input files

```
cd MITgcm/mysetups/ECCOv4
wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release3/input_forcing/
wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release3/input_init/
mv mit.ecco-group.org/ecco_for_las/version_4/release3/input_forcing .
mv mit.ecco-group.org/ecco_for_las/version_4/release3/input_init .
```

### setup the run directory

```
cd MITgcm/mysetups/ECCOv4
mkdir run
cd run
ln -s ../build/mitgcmuv .
ln -s ../input/* .
ln -s ../input_init/* .
ln -s ../input_forcing/* .
```

### run the model

`mpiexec -np 96 ./mitgcmuv`
