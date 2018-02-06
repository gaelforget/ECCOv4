
The `ECCO v4 r2` state estimate output is permanently archived within the `Harvard Dataverse <https://dataverse.harvard.edu/dataverse/ECCOv4r2>`__ that provides citable identifiers for the various datasets as reported in this `README.pdf <https://dataverse.harvard.edu/api/access/datafile/2863409>`__. For direct download purposes, the `ECCO v4 r2` output is also made available via this `ftp
server <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/>`__ by the `ECCO Consortium <http://ecco-group.org>`__. The various directory contents are summarized in this `README <http://mit.ecco-group.org/opendap/ecco_for_las/version_4/release2/README>`__ and specific details are provided in each subdirectory’s README. Under Linux or macOS for instance, a simple download method consists in using ``wget`` at the command line by typing

::

    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/nctiles_grid
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/nctiles_climatology
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/nctiles_monthly

and similarly for the other directories. The ``nctiles_`` directory prefix indicates that contents are provided on the native LLC90 grid in the nctiles format :cite:`for-eta:15` which can be read in `Matlab` using the `gcmfaces` toolbox (see :numref:`download-analysis`). Alternatively users can download interpolated fields, on a :math:`1/2\times1/2^\circ` grid in the netcdf format, from the ``interp_*`` directories. The ``input_*`` directories contain binary and netcdf input files that can be read by `MITgcm` (:numref:`eccov4-baseline`). The ``profiles/`` directory additionally contains the MITprof, netcdf collections of collocated in situ and state estimate profiles :cite:`for-eta:15`.

