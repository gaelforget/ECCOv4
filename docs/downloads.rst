
.. _downloads:

Downloading ECCO Version 4
**************************

This section provides directions to download the ECCO v4 r2 output 
(:numref:`download-solution`), the underlying model setup 
(:numref:`download-setup`) that can be used to re-run ECCO v4 r2 
(:numref:`eccov4-baseline`), `Matlab` tools to analyze ECCO v4 r2 and
other model output (:numref:`download-analysis`), and a list of
additional resources (:numref:`other-resources`).

.. _download-solution:

The Release 2 Solution
----------------------

The ECCO v4 r2 state estimate output is permanently archived within the
`Harvard Dataverse <https://dataverse.harvard.edu/dataverse/ECCOv4r2>`__
that provides citable identifiers for the various datasets as reported
in this
`README.pdf <https://dataverse.harvard.edu/api/access/datafile/2863409>`__.
For download purposes, the ECCO v4 r2 output is also made available via
this `ftp
server <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/>`__ by
the `ECCO Consortium <http://ecco-group.org>`__. The various directory
contents are summarized in this
`README <http://mit.ecco-group.org/opendap/ecco_for_las/version_4/release2/README>`__
and specific details are provided in each subdirectory’s README. Under
Linux or macOS for instance, a simple download method consists in using
``wget`` at the command line by typing

::

    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/nctiles_grid
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/nctiles_climatology
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/nctiles_monthly

and similarly for the other directories. The ``nctiles_*`` directory
prefix indicates that contents are provided on the native LLC90 grid in
the nctiles format :cite:`for-eta:15` which can be
read in `Matlab` using the `gcmfaces` toolbox (see
:numref:`download-analysis`). Alternatively users can
download interpolated fields, on a :math:`1/2\times1/2^\circ` grid in
the netcdf format, from the ``interp_*`` directories. The ``input_*``
directories contain binary and netcdf input files that can be read by
`MITgcm` (:numref:`download-setup` and :numref:`eccov4-baseline`). The 
`profiles directory <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/profiles/>`__
contains the MITprof collections of collocated in situ and state
estimate profiles in `netcdf` format
:cite:`for-eta:15`.

.. _download-setup:

The Release 2 Setup
-------------------

First, install the `MITgcm` either by downloading a copy from `this
webpage <http://mitgcm.org/download/other_checkpoints/>`__
(MITgcm_c66e.tar.gz is the latest release at present time) or by using
the `MITgcm cvs server <http://mitgcm.org/public/using_cvs.html>`__ as
explained in `that webpage <http://mitgcm.org/public/using_cvs.html>`__.
Second, create a subdirectory called ``MITgcm/mysetups/`` and install the
ECCO v4 r2 model setup in this directory either from `this github
repository <https://github.com/gaelforget/ECCO_v4_r2/>`__ by typing:

::

    mkdir MITgcm/mysetups
    cd MITgcm/mysetups
    git clone https://github.com/gaelforget/ECCO_v4_r2

or from the `MITgcm cvs
server <http://mitgcm.org/public/using_cvs.html>`__ by typing:

::

    mkdir MITgcm/mysetups
    cd MITgcm/mysetups
    cvs co -P -d ECCO_v4_r2 MITgcm_contrib/gael/verification/ECCO_v4_r2

or by downloading a copy via `this
webpage <http://mit.ecco-group.org/opendap/ecco_for_las/version_4/checkpoints/>`__
(c66e_eccov4r2.tar at present time). Third, download the three-hourly
forcing fields (96G; to re-run ECCO v4 r2 in
:numref:`eccov4-baseline`) and observational data (25G; to
verify ECCO v4 r2 re-runs in :numref:`eccov4-baseline`) model
inputs either from the `Harvard
Dataverse <https://dataverse.harvard.edu/dataverse/ECCOv4r2inputs>`__
permanent archive or from the `ECCO ftp
server <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/>`__ as
follows:

::

    cd MITgcm/mysetups/ECCO_v4_r2
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/input_forcing/
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/input_ecco/
    wget --recursive ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/input_init/
    mv mit.ecco-group.org/ecco_for_las/version_4/release2/input_forcing forcing_baseline2
    mv mit.ecco-group.org/ecco_for_las/version_4/release2/input_ecco inputs_baseline2
    mv mit.ecco-group.org/ecco_for_las/version_4/release2/input_init inputs_baseline2/.

:ref:`mitgcmdirs` provides a graphical depiction of
the downloaded directories organized as is expected in
:numref:`eccov4-baseline`. Experienced users should feel free
to re-organize directories assuming that they are comfortable with
modifying the :numref:`eccov4-baseline` and
the :ref:`baseline` instructions accordingly.

.. _download-analysis:

Matlab Analysis Tools
---------------------

`Matlab` tools are provided to analyze model output from 
:numref:`download-solution` or :numref:`eccov4-baseline` 
include the `gcmfaces` toolbox :cite:`for-eta:15`
gets installed as explained in the
`gcmfaces.pdf <http://mitgcm.org/viewvc/*checkout*/MITgcm/MITgcm_contrib/gael/matlab_class/gcmfaces.pdf>`__
documentation. It can be used, for example, to re-generate the
ECCO v4 standard analysis (i.e., the plots included in
:cite:`dspace-eccov4r2` for ECCO v4 r2) from the released model output
(:numref:`download-solution`) or from the plain, binary,
model output (:numref:`eccov4-baseline`).

.. _other-resources:

Other Resources
---------------

-  The stand-alone
   `eccov4_lonlat.m <http://mit.ecco-group.org/opendap/ecco_for_las/version_4/release2/doc/eccov4_lonlat.m>`__
   `Matlab` script can be used to extract the lat-lon sector (i.e., array)
   of the gridded output that spans the 69S to
   56N latitude range.
-  Any `netcdf` enabled software (e.g.,
   `Panoply <http://www.giss.nasa.gov/tools/panoply/>`__ in MS-Windows,
   Linux, or macOS) should be able to read the interpolated output for
   `the monthly
   climatology <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/interp_climatology/>`__
   or `the monthly time
   series <ftp://mit.ecco-group.org/ecco_for_las/version_4/release2/interp_monthly/>`__.

-  The ECCO v4 r2 state estimate can also be downloaded and analyzed via
   the `NASA` Sea Level Change Portal tools (https://sealevel.nasa.gov;
   interpolated fields only) and the `Harvard Dataverse` APIs
   (https://dataverse.harvard.edu; all inputs and outputs).

-  xmitgcm provides a `python` alternative
   (https://github.com/xgcm/xmitgcm) to using `Matlab` and `gcmfaces`
   (https://github.com/gaelforget/gcmfaces)

-  The `MITgcm/utils/ <http://mitgcm.org/viewvc/MITgcm/MITgcm/utils/>`__
   directory which can be downloaded via the `MITgcm` `cvs
   server <http://mitgcm.org/public/using_cvs.html>`__ and provides
   basic `Matlab` and `python` functionalities.

-  A series of three presentations offered in May 2016 during the `ECCO`
   meeting at `MIT` provide an overview of the ECCO v4 r2 data sets and
   applications are available via researchgate.net
   (`doi.org/10.13140/RG.2.2.33361.12647 <http://doi.org/10.13140/RG.2.2.33361.12647>`__;
   `doi.org/10.13140/RG.2.2.26650.24001 <http://doi.org/10.13140/RG.2.2.26650.24001>`__;
   `doi.org/10.13140/RG.2.2.36716.56967 <http://doi.org/10.13140/RG.2.2.36716.56967>`__).

