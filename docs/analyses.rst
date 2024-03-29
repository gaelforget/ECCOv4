
.. _analyses:

Analyze
*******

This section is focused on tools for analyzing outputs (:numref:`download-analysis`), and 
additional resources (:numref:`other-resources`).

.. _download-analysis:

Julia Toolbox
-------------

To be continued ... 

Python Toolbox
--------------

To be continued ... 

Matlab Toolbox
--------------

The `gcmfaces` toolbox :cite:`for-eta:15` can be used to analyze model output that has either been downloaded (:numref:`download-solution`) or reproduced (:numref:`eccov4-baseline`) by users. From the command line, you can install either the `Matlab` version by executing:

:: 

    git clone https://github.com/gaelforget/gcmfaces

or the `Octave` version by executing:

::

    git clone -b octave https://github.com/gaelforget/gcmfaces

The `gcmfaces` toolbox can be used, e.g., to reproduce the `standard analysis` (i.e., the plots in :cite:`dspace-eccov4r2`) from released, nctiles model output (:numref:`download-solution`) or from plain, binary model output (:numref:`eccov4-baseline`). For more information, please consult `the gcmfaces user guide <http://gcmfaces.readthedocs.io/en/latest/>`__.

.. _other-resources:

Other Resources
---------------

-  A series of three presentations given during the May 2016 `ECCO` meeting at `MIT` provides an overview of `ECCO v4` data sets, capabilities, and applications
   (`Overview <http://doi.org/10.13140/RG.2.2.33361.12647>`__;
   `Processes <http://doi.org/10.13140/RG.2.2.26650.24001>`__;
   `Tracers <http://doi.org/10.13140/RG.2.2.36716.56967>`__).

-  Various Python tools are available to analyse model output (see, e.g., `this tutorial <https://github.com/ECCO-GROUP/ECCO-v4-Python-Tutorial>`__).

-  Any `netcdf` enabled software such as `Panoply <http://www.giss.nasa.gov/tools/panoply/>`__ (available for `MS-Windows`, `Linux`, or `macOS`) can be used to plot the interpolated output (``interp_*`` directories).

-  The stand-alone `eccov4_lonlat.m <http://mit.ecco-group.org/opendap/ecco_for_las/version_4/release2/doc/eccov4_lonlat.m>`__ program can be used to extract the lat-lon sector, which spans the 69S to 56N latitude range, of native grid fields :cite:`for-eta:15`.

-  `ECCO v4` estimates can be plotted via the `NASA` `Sea Level Change Portal <https://sealevel.nasa.gov>`__ tools (interpolated output) or downloaded from the `Harvard Dataverse <https://dataverse.harvard.edu>`__ APIs (native grid input and output).

