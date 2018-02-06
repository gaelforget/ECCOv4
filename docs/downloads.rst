
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

.. include:: eccov4r2_output.rst

.. _download-setup:

The Release 2 Setup
-------------------

.. include:: eccov4r2_setup.rst

.. _download-analysis:

The Gcmfaces Toolbox
--------------------

The `gcmfaces` toolbox :cite:`for-eta:15` can be used to analyze model output that has either been downloaded (:numref:`download-solution`) or generated (:numref:`eccov4-baseline`) by user. Matlab and Octave implementations are available in `this repository <https://github.com/gaelforget/gcmfaces>`__. They can be installed by typing, at the command line, either

:: 

    git clone https://github.com/gaelforget/gcmfaces

or

::

    git clone -b octave https://github.com/gaelforget/gcmfaces

It can be used, for example, to re-generate the ECCO v4 standard analysis (i.e., the plots included in :cite:`dspace-eccov4r2` for ECCO v4 r2) from the released model output (:numref:`download-solution`) or from the plain, binary, model output (:numref:`eccov4-baseline`). Documentation for `gcmfaces` is provided in the `github repository <https://github.com/gaelforget/gcmfaces>`__.


.. _other-resources:

Other Resources
---------------

-  The ECCO v4 r2 state estimate can also be downloaded from the `NASA` `Sea Level Change Portal <https://sealevel.nasa.gov>`__ tools (interpolated output) or the `Harvard Dataverse <https://dataverse.harvard.edu>`__ APIs (native grid input and output).

-  A series of three presentations given at the May 2016 `MIT` ECCO meeting that provide an overview of the ECCO v4 r2 data sets and applications
   (`Overview <http://doi.org/10.13140/RG.2.2.33361.12647>`__;
   `Processes <http://doi.org/10.13140/RG.2.2.26650.24001>`__;
   `Tracers <http://doi.org/10.13140/RG.2.2.36716.56967>`__).

-  Any `netcdf` enabled software such as `Panoply <http://www.giss.nasa.gov/tools/panoply/>`__ (available for `MS-Windows`, `Linux`, or `macOS`) can be used to plot the interpolated output (``interp_*`` directories).

-  Various python tools are also available for analysis purposes (see `this python tutorial <https://github.com/ECCO-GROUP/ECCO-v4-Python-Tutorial>`__).

-  The ``MITgcm/utils/`` directory also provides basic `Matlab` and `python` functionalities.

-  The stand-alone `eccov4_lonlat.m <http://mit.ecco-group.org/opendap/ecco_for_las/version_4/release2/doc/eccov4_lonlat.m>`__ `Matlab` script can be used to extract the lat-lon sector (i.e., array) of the gridded output that spans the 69S to 56N latitude range.
