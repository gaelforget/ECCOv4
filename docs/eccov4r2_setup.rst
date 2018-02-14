
Users can donwload the `MITgcm` from `this github repository <https://github.com/MITgcm/MITgcm/>`__ and the model setup there from `that github repository <https://github.com/gaelforget/ECCOv4/>`__ by typing:

::

    git clone https://github.com/MITgcm/MITgcm
    git clone https://github.com/gaelforget/ECCOv4
    mkdir MITgcm/mysetups
    mv ECCOv4 MITgcm/mysetups/.

Re-running `ECCO v4 r2` additionally requires downloading surface forcing input (96G of 6-hourly fields in `ECCO v4 r2`), initial condition, grid, etc. input (610M), and observational input (25G) either from the `Harvard Dataverse <https://dataverse.harvard.edu/dataverse/ECCOv4r2inputs>`__ permanent archive or directly from the `ECCO ftp server <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/>`__ as follows:

::

    cd MITgcm/mysetups/ECCOv4
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/input_forcing/
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/input_init/
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/input_ecco/
    mv mit.ecco-group.org/ecco_for_las/version_4/release2/input_forcing forcing_baseline2
    mv mit.ecco-group.org/ecco_for_las/version_4/release2/input_ecco inputs_baseline2
    mv mit.ecco-group.org/ecco_for_las/version_4/release2/input_init inputs_baseline2/.

