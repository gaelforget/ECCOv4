
`ECCO V4r2` was the first update to the original ECCO V4 solution :cite:`for-eta:15` with : 

#. additional corrections listed in :cite:`dspace-eccov4r2`
#. additional model-data misfit and model budget output
#. easier to rerun than ECCO version 4 release 1

The main `ECCO V4r2` output is permanently archived in `this Dataverse <https://dataverse.harvard.edu/dataverse/ECCOv4r2>`__ , 
which provides citable identifiers for the various datasets. 
See this `README.pdf <https://dataverse.harvard.edu/api/access/datafile/2863409>`__ for detail. 
For direct downloads we recommend `Dataverse.jl <https://github.com/gdcc/Dataverse.jl#readme>`__ in `Julia <https://julialang.org>`__.

In the archive, folders that start with ``nctiles_`` contain data on the native LLC90 grid in the nctiles format :cite:`for-eta:15`. 
This format is easily read in `Julia`, `Python`, and `Matlab/Octave` (see :numref:`download-analysis`). 

.. note::

   Alternatively users can download interpolated fields, on a :math:`1/2\times1/2^\circ` grid in the netcdf format, from `ecco-group.org <https://ecco-group.org/products.htm>`.

The ``input_*`` directories contain binary and netcdf input files that can be read by `MITgcm` (:numref:`eccov4-baseline`). 
The ``profiles/`` directory additionally contains the MITprof, netcdf collections of collocated in situ and state estimate profiles :cite:`for-eta:15`.
